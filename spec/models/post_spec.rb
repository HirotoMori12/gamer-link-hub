require "rails_helper"

RSpec.describe Post, type: :model do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:post)).to be_valid
    end

    it "requires a body" do
      expect(build(:post, body: nil)).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a user and a guild" do
      post = create(:post)

      expect(post.user).to be_a(User)
      expect(post.guild).to be_a(Guild)
    end

    it "destroys its images when destroyed" do
      post = create(:post)
      post.images.create!(image_url: "https://example.com/a.png")

      expect { post.destroy }.to change(Image, :count).by(-1)
    end

    it "can be tagged through post_tags" do
      post = create(:post)
      tag = create(:tag, guild: post.guild)

      post.tags << tag

      expect(post.reload.tags).to include(tag)
    end

    it "removes the post_tag join record but keeps the tag when destroyed" do
      post = create(:post)
      tag = create(:tag, guild: post.guild)
      post.tags << tag

      expect { post.destroy }.to change(PostTag, :count).by(-1)
      expect(Tag.exists?(tag.id)).to be true
    end
  end
end
