class SavePostFromDiscordJob < ApplicationJob
  queue_as :default

  def perform(interaction_data)
    # Interaction dataから必要な情報を抽出
    guild_id = interaction_data["guild_id"]
    user_data = interaction_data["member"]["user"]
    target_message_id = interaction_data["data"]["target_id"]
    target_message = interaction_data["data"]["resolved"]["messages"][target_message_id]
    interaction_token = interaction_data["token"]

    # Guildを取得(存在しない場合はDBに保存されていない=登録されていないサーバー)
    guild = Guild.find_by(discord_guild_id: guild_id)
    unless guild
      send_followup(interaction_token, "❌ このサーバーではGamer Link Hubが利用できません")
      return
    end

    # Userを取得(ログイン済みのユーザーのみ)
    user = User.find_by(discord_uid: user_data["id"])
    unless user
      send_followup(interaction_token, "❌ まず https://gamer-link-hub.onrender.com からログインしてください")
      return
    end

    # 投稿を保存
    post = user.posts.create!(
      guild: guild,
      body: target_message["content"] || "(本文なし)",
      discord_message_id: target_message_id
    )

    # 画像の保存(Cloudinary対応は次のIssueで)
    target_message["attachments"]&.each do |attachment|
      post.images.create!(image_url: attachment["url"])
    end

    # 完了通知
    send_followup(interaction_token, "✅ 保存しました!(ID: #{post.id})")
  rescue => e
    Rails.logger.error "SavePostFromDiscordJob failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    send_followup(interaction_token, "❌ 保存に失敗しました: #{e.message}") if interaction_token
  end

  private

  def send_followup(interaction_token, content)
    client = Discord::ApiClient.new
    client.create_followup_message(interaction_token: interaction_token, content: content)
  end
end
