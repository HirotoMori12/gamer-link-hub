FactoryBot.define do
  factory :post do
    user
    guild
    body { "テスト投稿の本文です" }
    sequence(:discord_message_id) { |n| "discord_message_id_#{n}" }
  end
end
