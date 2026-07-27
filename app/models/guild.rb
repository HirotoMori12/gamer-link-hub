class Guild < ApplicationRecord
  has_many :user_guilds, dependent: :destroy
  has_many :users, through: :user_guilds

  validates :discord_guild_id, presence: true, uniqueness: true
  validates :name, presence: true

  def self.find_or_create_from_discord(guild_data)
    find_or_create_by(discord_guild_id: guild_data["id"]) do |guild|
      guild.name = guild_data["name"]
    end
  end
end
