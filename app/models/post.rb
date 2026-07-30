class Post < ApplicationRecord
  belongs_to :user
  belongs_to :guild

  has_many :images, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
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
end
