FactoryBot.define do
  factory :guild do
    sequence(:discord_guild_id) { |n| "discord_guild_id_#{n}" }
    sequence(:name) { |n| "Guild #{n}" }
  end
end
