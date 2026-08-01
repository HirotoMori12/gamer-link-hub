require "net/http"
require "uri"
require "open-uri"

class SavePostFromDiscordJob < ApplicationJob
  queue_as :default

  def perform(interaction_data)
    interaction_token = interaction_data["token"]

    guild = find_guild(interaction_data)
    unless guild
      send_followup(interaction_token, "❌ このサーバーはまだ利用登録されていません。メンバーの誰か1人が一度 https://gamer-link-hub.onrender.com からログインしてサーバーを選択すると使えるようになります")
      return
    end

    user = find_user(interaction_data)
    unless user
      send_followup(interaction_token, "❌ まず https://gamer-link-hub.onrender.com からログインしてください")
      return
    end

    target_message_id = interaction_data.dig("data", "target_id")
    target_message = interaction_data.dig("data", "resolved", "messages", target_message_id)

    post = create_post(user: user, guild: guild, message: target_message, discord_message_id: target_message_id)
    attach_images!(post, target_message["attachments"])

    send_followup(interaction_token, "✅ 保存しました!(ID: #{post.id})")
  rescue => e
    Rails.logger.error "SavePostFromDiscordJob failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    if interaction_token
      send_followup(interaction_token, "❌ 保存に失敗しました: #{e.message}")
    end
  end

  private

  def find_guild(interaction_data)
    Guild.find_by(discord_guild_id: interaction_data["guild_id"])
  end

  def find_user(interaction_data)
    user_data = interaction_data["member"]["user"]
    User.find_by(discord_uid: user_data["id"])
  end

  def create_post(user:, guild:, message:, discord_message_id:)
    # メッセージ本文の抽出(空だった場合の対処)
    message_body = message["content"].presence || "(本文なし)"
    user.posts.create!(guild: guild, body: message_body, discord_message_id: discord_message_id)
  end

  # 画像をCloudinaryにアップロードして保存(失敗時は元のDiscord URLをそのままフォールバック保存)
  def attach_images!(post, attachments)
    attachments&.each do |attachment|
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
  end

  def send_followup(interaction_token, content)
    client = Discord::ApiClient.new
    client.create_followup_message(interaction_token: interaction_token, content: content)
  end
end
