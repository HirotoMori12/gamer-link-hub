require "rails_helper"

RSpec.describe PostLink, type: :model do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:post_link)).to be_valid
    end

    it "requires a unique related_post_id within the same post" do
      guild = create(:guild)
      post = create(:post, guild: guild)
      other = create(:post, guild: guild)
      create(:post_link, post: post, related_post: other)

      expect(build(:post_link, post: post, related_post: other)).not_to be_valid
    end

    it "does not allow linking a post to itself" do
      post = create(:post)

      expect(build(:post_link, post: post, related_post: post)).not_to be_valid
    end

    it "does not allow linking posts across different guilds" do
      post = create(:post, guild: create(:guild))
      other = create(:post, guild: create(:guild))

      expect(build(:post_link, post: post, related_post: other)).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a post and a related_post" do
      link = create(:post_link)

      expect(link.post).to be_a(Post)
      expect(link.related_post).to be_a(Post)
    end
  end
end
