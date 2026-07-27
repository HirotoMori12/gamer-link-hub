require "net/http"
require "json"

class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_omniauth(auth)

    if user.persisted?
      # Discord APIから所属Guild一覧を取得
      guilds_data = fetch_user_guilds(auth.credentials.token)
      user.sync_guilds_from_discord(guilds_data) if guilds_data

      session[:user_id] = user.id
      redirect_to root_path, notice: "ログインしました"
    else
      redirect_to root_path, alert: "ログインに失敗しました"
    end
  end

  def destroy
    session.delete(:user_id)
    session.delete(:current_guild_id)
    redirect_to root_path, notice: "ログアウトしました"
  end

  private

  def fetch_user_guilds(access_token)
    uri = URI("https://discord.com/api/users/@me/guilds")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code == "200"
      JSON.parse(response.body)
    else
      Rails.logger.error "Failed to fetch guilds: #{response.code} #{response.body}"
      nil
    end
  rescue => e
    Rails.logger.error "Error fetching guilds: #{e.message}"
    nil
  end
end
