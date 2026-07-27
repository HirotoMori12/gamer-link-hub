class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_omniauth(auth)

    if user.persisted?
      session[:user_id] = user.id
      redirect_to root_path, notice: "ログインしました"
    else
      redirect_to root_path, alert: "ログインに失敗しました"
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "ログアウトしました"
  end
end
