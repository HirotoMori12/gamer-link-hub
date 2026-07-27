class GuildsController < ApplicationController
  before_action :require_login

  def index
    @guilds = current_user.guilds
  end

  def select
    guild = current_user.guilds.find(params[:id])
    session[:current_guild_id] = guild.id
    redirect_to root_path, notice: "#{guild.name} を選択しました"
  end
end
