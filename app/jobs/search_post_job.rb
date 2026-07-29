class SearchPostJob < ApplicationJob
  queue_as :default

  def perform(interaction_data)
    guild_id = interaction_data["guild_id"]
    interaction_token = interaction_data["token"]

    # キーワードを取得
    options = interaction_data.dig("data", "options") || []
    keyword_option = options.find { |opt| opt["name"] == "keyword" }
    keyword = keyword_option&.dig("value")

    guild = Guild.find_by(discord_guild_id: guild_id)
    unless guild
      send_followup(interaction_token, content: "このサーバーではGamer Link Hubが利用できません")
      return
    end

    posts = PostSearcher.new(guild: guild, keyword: keyword).search

    if posts.empty?
      send_followup(interaction_token, content: "「#{keyword}」に一致する投稿が見つかりませんでした")
      return
    end

    # Discord Embedsとして整形
    embeds = posts.map do |post|
      {
        title: post.body.truncate(80),
        description: post.tags.any? ? "タグ: #{post.tags.map(&:name).join(', ')}" : nil,
        color: 0x5865F2,
        timestamp: post.created_at.iso8601,
        footer: { text: "投稿ID: #{post.id}" }
      }.compact
    end

    send_followup(
      interaction_token,
      content: "「#{keyword}」の検索結果:#{posts.size}件",
      embeds: embeds
    )
  rescue => e
    Rails.logger.error "SearchPostJob failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    if interaction_token
      send_followup(interaction_token, content: "❌ 検索に失敗しました: #{e.message}")
    end
  end

  private

  def send_followup(interaction_token, content: nil, embeds: nil)
    client = Discord::ApiClient.new
    client.create_followup_message_with_embeds(
      interaction_token: interaction_token,
      content: content,
      embeds: embeds
    )
  end
end
