class PostsController < ApplicationController
  before_action :require_login
  before_action :require_guild_selection
  before_action :set_post, only: [:show]

  def index
    @posts = current_guild.posts.includes(:user, :tags, :images)

    if params[:keyword].present?
      @posts = @posts.ransack(
        m: "or",
        body_cont: params[:keyword],
        tags_name_cont: params[:keyword]
      ).result(distinct: true)
    end

    if params[:tag_id].present?
      @posts = @posts.joins(:tags).where(tags: { id: params[:tag_id] })
    end

    @posts = @posts.order(created_at: :desc)
    @tags = current_guild.tags.order(:name)
  end

  def show
    # 本人の投稿かどうかを判定
    @is_owner = @post.user_id == current_user.id
  end

  private

  def set_post
    # current_guildのpostだけアクセス可能(他Guildへの不正アクセス防止)
    @post = current_guild.posts.includes(:user, :tags, :images).find(params[:id])
  end
end
