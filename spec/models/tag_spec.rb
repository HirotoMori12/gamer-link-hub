require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:tag)).to be_valid
    end

    it "requires a name" do
      expect(build(:tag, name: nil)).not_to be_valid
    end

    it "requires a unique name within the same guild" do
      guild = create(:guild)
      create(:tag, guild: guild, name: "VRChat")

      expect(build(:tag, guild: guild, name: "VRChat")).not_to be_valid
    end

    it "allows the same name across different guilds" do
      create(:tag, name: "VRChat")

      expect(build(:tag, name: "VRChat")).to be_valid
    end
  end

  describe "associations" do
    it "belongs to a guild" do
      tag = create(:tag)

      expect(tag.guild).to be_a(Guild)
    end

    it "has many posts through post_tags" do
      tag = create(:tag)
      post = create(:post, guild: tag.guild)
      post.tags << tag

      expect(tag.reload.posts).to include(post)
    end
  end
end
