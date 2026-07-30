FactoryBot.define do
  factory :user do
    sequence(:discord_uid) { |n| "discord_uid_#{n}" }
    sequence(:username) { |n| "user#{n}" }
    avatar_url { "https://example.com/avatar.png" }
  end
end
