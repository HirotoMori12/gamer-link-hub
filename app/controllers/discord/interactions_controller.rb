module Discord
  class InteractionsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :verify_discord_signature

    # Interactionタイプ
    PING = 1
    APPLICATION_COMMAND = 2
    MESSAGE_COMPONENT = 3

    # レスポンスタイプ
    PONG = 1
    CHANNEL_MESSAGE_WITH_SOURCE = 4
    DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE = 5

    # Application Commandタイプ
    CHAT_INPUT = 1
    USER = 2
    MESSAGE = 3

    # メッセージフラグ
    EPHEMERAL = 64

    def create
      case interaction_data[:type]
      when PING
        render json: { type: PONG }
      when APPLICATION_COMMAND
        handle_application_command
      else
        render json: { error: "Unsupported interaction type" }, status: :bad_request
      end
    end

    private

    def handle_application_command
      command_type = interaction_data.dig(:data, :type)
      command_name = interaction_data.dig(:data, :name)

      if command_type == MESSAGE && command_name == "この情報を保存"
        # 3秒以内に返す必要があるので、まずDeferred Responseを返す
        # ephemeral(実行者のみ表示)フラグを立てる
        SavePostFromDiscordJob.perform_later(interaction_data.deep_stringify_keys)

        render json: {
          type: DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE,
          data: { flags: EPHEMERAL }
        }
      elsif command_type == CHAT_INPUT && command_name == "search"
        handle_search_command
      else
        render json: {
          type: CHANNEL_MESSAGE_WITH_SOURCE,
          data: { content: "不明なコマンドです", flags: EPHEMERAL }
        }
      end
    end

    def handle_search_command
      guild_id = interaction_data[:guild_id]
      # /search コマンドの引数からキーワードを取得
      keyword = interaction_data.dig(:data, :options)&.find { |opt| opt[:name] == "keyword" }&.dig(:value)

      guild = Guild.find_by(discord_guild_id: guild_id)
      unless guild
        render json: {
          type: CHANNEL_MESSAGE_WITH_SOURCE,
          data: {
            content: "このサーバーではGamer Link Hubが利用できません",
            flags: EPHEMERAL
          }
        }
        return
      end

      posts = PostSearcher.new(guild: guild, keyword: keyword).search

      if posts.empty?
        render json: {
          type: CHANNEL_MESSAGE_WITH_SOURCE,
          data: {
            content: "「#{keyword}」に一致する投稿が見つかりませんでした",
            flags: EPHEMERAL
          }
        }
        return
      end

      # Discord Embedsとして整形
      embeds = posts.map do |post|
        {
          title: post.body.truncate(80),
          description: post.tags.any? ? "タグ: #{post.tags.map(&:name).join(', ')}" : nil,
          color: 0x5865F2, # Discord Blurple color
          timestamp: post.created_at.iso8601,
          footer: { text: "投稿ID: #{post.id}" }
        }.compact
      end

      render json: {
        type: CHANNEL_MESSAGE_WITH_SOURCE,
        data: {
          content: "「#{keyword}」の検索結果:#{posts.size}件",
          embeds: embeds,
          flags: EPHEMERAL
        }
      }
    end

    def interaction_data
      @interaction_data ||= JSON.parse(request.raw_post, symbolize_names: true)
    rescue JSON::ParserError
      {}
    end

    def verify_discord_signature
      signature = request.headers["X-Signature-Ed25519"]
      timestamp = request.headers["X-Signature-Timestamp"]
      body = request.raw_post

      verifier = Discord::SignatureVerifier.new
      unless verifier.verify(signature: signature, timestamp: timestamp, body: body)
        head :unauthorized
      end
    end
  end
end
