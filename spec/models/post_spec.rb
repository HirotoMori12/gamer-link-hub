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

  describe "#link_with!" do
    it "links two posts to each other symmetrically" do
      guild = create(:guild)
      post_a = create(:post, guild: guild)
      post_b = create(:post, guild: guild)

      post_a.link_with!(post_b.id)

      expect(post_a.reload.related_posts).to include(post_b)
      expect(post_b.reload.related_posts).to include(post_a)
    end

    it "does not link a post to itself" do
      post = create(:post)

      expect { post.link_with!(post.id) }.not_to change(PostLink, :count)
    end

    it "is idempotent when called twice for the same pair" do
      guild = create(:guild)
      post_a = create(:post, guild: guild)
      post_b = create(:post, guild: guild)

      post_a.link_with!(post_b.id)

      expect { post_a.link_with!(post_b.id) }.not_to change(PostLink, :count)
    end
  end

  describe "#unlink_from!" do
    it "removes the link in both directions" do
      guild = create(:guild)
      post_a = create(:post, guild: guild)
      post_b = create(:post, guild: guild)
      post_a.link_with!(post_b.id)

      post_a.unlink_from!(post_b.id)

      expect(post_a.reload.related_posts).not_to include(post_b)
      expect(post_b.reload.related_posts).not_to include(post_a)
    end
  end

  describe "#sync_related_posts!" do
    it "adds new links and removes ones no longer selected" do
      guild = create(:guild)
      post = create(:post, guild: guild)
      keep = create(:post, guild: guild)
      drop = create(:post, guild: guild)
      add = create(:post, guild: guild)
      post.link_with!(keep.id)
      post.link_with!(drop.id)

      post.sync_related_posts!([keep.id, add.id])

      expect(post.related_posts.reload).to contain_exactly(keep, add)
      expect(drop.reload.related_posts).not_to include(post)
    end

    it "ignores posts from other guilds" do
      post = create(:post, guild: create(:guild))
      other_guild_post = create(:post, guild: create(:guild))

      post.sync_related_posts!([other_guild_post.id])

      expect(post.related_posts.reload).to be_empty
    end

    it "clears all links when given a blank value" do
      guild = create(:guild)
      post = create(:post, guild: guild)
      other = create(:post, guild: guild)
      post.link_with!(other.id)

      post.sync_related_posts!(nil)

      expect(post.related_posts.reload).to be_empty
    end
  end
end
