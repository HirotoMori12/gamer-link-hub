class PostsController < ApplicationController
  before_action :require_login
  before_action :require_guild_selection
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :require_owner!, only: [:edit, :update, :destroy]

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

  def edit
  end

  def update
    @post.assign_attributes(post_params)

    if @post.valid?
      ActiveRecord::Base.transaction do
        @post.save!
        sync_tags!
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
    @post = current_guild.posts.includes(:user, :tags, :images).find(params[:id])
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

  # タグ名(カンマ区切り)から投稿とタグの紐づけを同期する(追加・削除の両方に対応)
  def sync_tags!
    names = params[:post][:tag_names].to_s.split(/[,、\s]+/).map(&:strip).reject(&:blank?).uniq
    @post.tags = names.map { |name| current_guild.tags.find_or_create_by!(name: name) }
  end
end
