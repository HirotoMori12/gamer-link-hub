class PostsController < ApplicationController
  before_action :require_login
  before_action :require_guild_selection
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :require_owner!, only: [:edit, :update, :destroy]

  def index
    @posts = current_guild.posts
                           .includes(:user, :tags, :images)
                           .with_attached_attached_images
                           .search_by_keyword(params[:keyword])
                           .tagged_with(params[:tag_id])
                           .order(created_at: :desc)
    @tags = current_guild.tags.order(:name)
  end

  def show
    # 本人の投稿かどうかを判定
    @is_owner = @post.user_id == current_user.id
  end

  def edit
  end

  def update
    @post.assign_attributes(post_params)

    if @post.valid?
      ActiveRecord::Base.transaction do
        @post.save!
        @post.sync_tags_from_names!(params[:post][:tag_names])
      end
      redirect_to @post, notice: "更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "削除しました"
  end

  private

  def set_post
    # current_guildのpostだけアクセス可能(他Guildへの不正アクセス防止)
    @post = current_guild.posts.includes(:user, :tags, :images).with_attached_attached_images.find(params[:id])
  end

  # 投稿者本人以外は編集・削除不可
  def require_owner!
    unless @post.user_id == current_user.id
      redirect_to @post, alert: "本人の投稿のみ編集・削除できます"
    end
  end

  def post_params
    params.require(:post).permit(:body)
  end
end
