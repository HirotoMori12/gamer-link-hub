class Post < ApplicationRecord
  belongs_to :user
  belongs_to :guild

  has_many :images, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  validates :body, presence: true
end
