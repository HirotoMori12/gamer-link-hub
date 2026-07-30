require "rails_helper"

RSpec.describe Guild, type: :model do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:guild)).to be_valid
    end

    it "requires a name" do
      expect(build(:guild, name: nil)).not_to be_valid
    end

    it "requires a discord_guild_id" do
      expect(build(:guild, discord_guild_id: nil)).not_to be_valid
    end

    it "requires a unique discord_guild_id" do
      existing = create(:guild)
      duplicate = build(:guild, discord_guild_id: existing.discord_guild_id)

      expect(duplicate).not_to be_valid
    end
  end

  describe "associations" do
    it "has many users through user_guilds" do
      guild = create(:guild)
      user = create(:user)
      create(:user_guild, user: user, guild: guild)

      expect(guild.users).to include(user)
    end

    it "destroys its posts and tags when destroyed" do
      guild = create(:guild)
      create(:post, guild: guild)
      create(:tag, guild: guild)

      expect { guild.destroy }.to change(Post, :count).by(-1).and change(Tag, :count).by(-1)
    end
  end

  describe ".find_or_create_from_discord" do
    it "creates a guild from discord data" do
      expect {
        described_class.find_or_create_from_discord("id" => "777", "name" => "新規サーバー")
      }.to change(described_class, :count).by(1)
    end

    it "does not create a duplicate for an existing discord_guild_id" do
      create(:guild, discord_guild_id: "777")

      expect {
        described_class.find_or_create_from_discord("id" => "777", "name" => "別名")
      }.not_to change(described_class, :count)
    end
  end
end
