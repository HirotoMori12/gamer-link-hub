class Post < ApplicationRecord
  belongs_to :user
  belongs_to :guild

  has_many :images, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  # Active Storageで画像を扱う
  has_many_attached :attached_images

  validates :body, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["body", "created_at", "discord_message_id", "id", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["tags"]
  end
end
