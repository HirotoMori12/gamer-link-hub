class Tag < ApplicationRecord
  belongs_to :guild

  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags

  validates :name, presence: true, uniqueness: { scope: :guild_id }

  def self.ransackable_attributes(auth_object = nil)
    ["name", "id", "created_at", "updated_at"]
  end
end
