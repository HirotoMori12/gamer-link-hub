class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?, :current_guild

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def current_guild
    return nil unless logged_in?
    @current_guild ||= current_user.guilds.find_by(id: session[:current_guild_id])
  end

  def require_login
    unless logged_in?
      redirect_to root_path, alert: "ログインが必要です"
    end
  end

  def require_guild_selection
    unless current_guild
      redirect_to guilds_path, alert: "サーバーを選択してください"
    end
  end
end
