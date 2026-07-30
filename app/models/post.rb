class Post < ApplicationRecord
  belongs_to :user
  belongs_to :guild

  has_many :images, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :post_links, dependent: :destroy
  has_many :related_posts, through: :post_links
  # Active Storageで画像を扱う
  has_many_attached :attached_images

  validates :body, presence: true

  scope :search_by_keyword, ->(keyword) {
    next all if keyword.blank?

    ransack(m: "or", body_cont: keyword, tags_name_cont: keyword).result(distinct: true)
  }

  scope :tagged_with, ->(tag_id) {
    next all if tag_id.blank?

    joins(:tags).where(tags: { id: tag_id })
  }

  def self.ransackable_attributes(auth_object = nil)
    ["body", "created_at", "discord_message_id", "id", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["tags"]
  end

  # タグ名(カンマ区切り)から投稿とタグの紐づけを同期する(追加・削除の両方に対応)
  def sync_tags_from_names!(names_string)
    names = names_string.to_s.split(/[,、\s]+/).map(&:strip).reject(&:blank?).uniq
    self.tags = names.map { |name| guild.tags.find_or_create_by!(name: name) }
  end

  # 選択された投稿IDと関連投稿を同期する(同一Guild内・自分自身を除く、追加・削除の両方に対応)
  def sync_related_posts!(target_post_ids)
    target_ids = guild.posts.where(id: target_post_ids).where.not(id: id).pluck(:id)
    current_ids = related_post_ids

    (target_ids - current_ids).each { |other_id| link_with!(other_id) }
    (current_ids - target_ids).each { |other_id| unlink_from!(other_id) }
  end

  # 投稿同士を相互にリンクする(A→B・B→Aの両方のレコードを作成)
  def link_with!(other_post_id)
    return if other_post_id.to_i == id

    ActiveRecord::Base.transaction do
      PostLink.find_or_create_by!(post_id: id, related_post_id: other_post_id)
      PostLink.find_or_create_by!(post_id: other_post_id, related_post_id: id)
    end
  end

  # 投稿同士のリンクを解除する(双方向とも削除)
  def unlink_from!(other_post_id)
    ActiveRecord::Base.transaction do
      PostLink.where(post_id: id, related_post_id: other_post_id).destroy_all
      PostLink.where(post_id: other_post_id, related_post_id: id).destroy_all
    end
  end
end
