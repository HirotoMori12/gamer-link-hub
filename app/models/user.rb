class User < ApplicationRecord
  validates :discord_uid, presence: true, uniqueness: true
  validates :username, presence: true

  def self.find_or_create_from_omniauth(auth)
    find_or_create_by(discord_uid: auth.uid) do |user|
      user.username = auth.info.name
      user.avatar_url = auth.info.image
    end
  end
end
