class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_omniauth(auth)

    if user.persisted?
      # Discord APIから所属Guild一覧を取得
      guilds_data = Discord::ApiClient.new.fetch_user_guilds(auth.credentials.token)
      user.sync_guilds_from_discord(guilds_data) if guilds_data

      session[:user_id] = user.id
      redirect_to guilds_path, notice: "ログインしました"
    else
      redirect_to root_path, alert: "ログインに失敗しました"
    end
  end

  def destroy
    session.delete(:user_id)
    session.delete(:current_guild_id)
    redirect_to root_path, notice: "ログアウトしました"
  end
end
