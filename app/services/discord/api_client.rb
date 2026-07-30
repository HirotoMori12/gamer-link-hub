require "net/http"
require "json"

module Discord
  class ApiClient
    BASE_URL = "https://discord.com/api/v10"

    def initialize(application_id: ENV["DISCORD_CLIENT_ID"], bot_token: ENV["DISCORD_BOT_TOKEN"])
      @application_id = application_id
      @bot_token = bot_token
    end

    # Deferred Response の後で送るフォローアップメッセージ
    def create_followup_message(interaction_token:, content:)
      post_json(followup_uri(interaction_token), body: { content: content }, action: "sending followup message")
    end

    # フォローアップメッセージにEmbedを含める版
    def create_followup_message_with_embeds(interaction_token:, content: nil, embeds: nil)
      body = {}
      body[:content] = content if content
      body[:embeds] = embeds if embeds
      post_json(followup_uri(interaction_token), body: body, action: "sending followup with embeds")
    end

    # 即時にEmbedを返す(Deferred Responseを使わない場合)
    # Note: このメソッドは使わない場合もあるが、参考として実装
    def create_message_with_embed(interaction_token:, embeds:)
      post_json(followup_uri(interaction_token), body: { embeds: embeds }, action: "sending embed message")
    end

    # ログインユーザーが所属するDiscordサーバー一覧を取得
    def fetch_user_guilds(access_token)
      uri = URI("https://discord.com/api/users/@me/guilds")
      get_json(uri, headers: { "Authorization" => "Bearer #{access_token}" }, action: "fetching user guilds")
    end

    private

    def followup_uri(interaction_token)
      URI("#{BASE_URL}/webhooks/#{@application_id}/#{interaction_token}")
    end

    def post_json(uri, body:, action:)
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = body.to_json
      perform_request(uri, request, action: action)
    end

    def get_json(uri, headers: {}, action:)
      request = Net::HTTP::Get.new(uri)
      headers.each { |key, value| request[key] = value }
      perform_request(uri, request, action: action)
    end

    # HTTPリクエストを実行し、成功時はJSONをパース、失敗時はログを残してnilを返す(共通処理)
    def perform_request(uri, request, action:)
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }

      if response.code.to_i.between?(200, 299)
        JSON.parse(response.body)
      else
        Rails.logger.error "Failed while #{action}: #{response.code} #{response.body}"
        nil
      end
    rescue => e
      Rails.logger.error "Error while #{action}: #{e.message}"
      nil
    end
  end
end
