class UserGuild < ApplicationRecord
  belongs_to :user
  belongs_to :guild

  validates :user_id, uniqueness: { scope: :guild_id }
end
