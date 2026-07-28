class User < ApplicationRecord
  has_many :user_guilds, dependent: :destroy
  has_many :guilds, through: :user_guilds
  has_many :posts, dependent: :destroy

  validates :discord_uid, presence: true, uniqueness: true
  validates :username, presence: true

  def self.find_or_create_from_omniauth(auth)
    find_or_create_by(discord_uid: auth.uid) do |user|
      user.username = auth.info.name
      user.avatar_url = auth.info.image
    end
  end

  def sync_guilds_from_discord(guilds_data)
    guilds_data.each do |guild_data|
      guild = Guild.find_or_create_from_discord(guild_data)
      user_guilds.find_or_create_by(guild: guild)
    end
  end
end
