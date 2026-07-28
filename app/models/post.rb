class Post < ApplicationRecord
  belongs_to :user
  belongs_to :guild

  has_many :images, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  # Active Storageで画像を扱う
  has_many_attached :attached_images

  validates :body, presence: true
end
