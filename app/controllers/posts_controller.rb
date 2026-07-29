class PostsController < ApplicationController
  before_action :require_login
  before_action :require_guild_selection

  def index
    @posts = current_guild.posts.includes(:user, :tags, :images)

    # キーワード検索(Ransack)
    if params[:keyword].present?
      @posts = @posts.ransack(
        m: "or",
        body_cont: params[:keyword],
        tags_name_cont: params[:keyword]
      ).result(distinct: true)
    end

    # タグ絞り込み
    if params[:tag_id].present?
      @posts = @posts.joins(:tags).where(tags: { id: params[:tag_id] })
    end

    @posts = @posts.order(created_at: :desc)
    @tags = current_guild.tags.order(:name)
  end
end
