FactoryBot.define do
  factory :post_link do
    transient do
      guild { create(:guild) }
    end

    post { create(:post, guild: guild) }
    related_post { create(:post, guild: guild) }
  end
end
