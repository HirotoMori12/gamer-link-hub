require "net/http"
require "uri"
require "open-uri"

class SavePostFromDiscordJob < ApplicationJob
  queue_as :default

  def perform(interaction_data)
    guild_id = interaction_data["guild_id"]
    user_data = interaction_data["member"]["user"]
    target_message_id = interaction_data["data"]["target_id"]
    target_message = interaction_data["data"]["resolved"]["messages"][target_message_id]
    interaction_token = interaction_data["token"]

    guild = Guild.find_by(discord_guild_id: guild_id)
    unless guild
      send_followup(interaction_token, "❌ このサーバーではGamer Link Hubが利用できません")
      return
    end

    user = User.find_by(discord_uid: user_data["id"])
    unless user
      send_followup(interaction_token, "❌ まず https://gamer-link-hub.onrender.com からログインしてください")
      return
    end

    # メッセージ本文の抽出(空だった場合の対処)
    message_body = target_message["content"].presence || "(本文なし)"

    post = user.posts.create!(
      guild: guild,
      body: message_body,
      discord_message_id: target_message_id
    )

    # 画像をCloudinaryにアップロードして保存
    target_message["attachments"]&.each do |attachment|
      # Discord CDNから画像をダウンロード
      downloaded_file = URI.open(attachment["url"])
      # Active Storage経由でCloudinaryにアップロード
      post.attached_images.attach(
        io: downloaded_file,
        filename: attachment["filename"],
        content_type: attachment["content_type"]
      )
    rescue => e
      Rails.logger.error "画像のCloudinaryアップロード失敗: #{e.message}"
      # 失敗した場合は元のDiscord URLをそのままDBに保存(フォールバック)
      post.images.create!(image_url: attachment["url"])
    end

    send_followup(interaction_token, "✅ 保存しました!(ID: #{post.id})")
  rescue => e
    Rails.logger.error "SavePostFromDiscordJob failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    if interaction_token
      send_followup(interaction_token, "❌ 保存に失敗しました: #{e.message}")
    end
  end

  private

  def send_followup(interaction_token, content)
    client = Discord::ApiClient.new
    client.create_followup_message(interaction_token: interaction_token, content: content)
  end
end
