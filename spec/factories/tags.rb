FactoryBot.define do
  factory :tag do
    guild
    sequence(:name) { |n| "tag#{n}" }
  end
end
