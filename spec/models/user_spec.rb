require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:user)).to be_valid
    end

    it "requires a username" do
      expect(build(:user, username: nil)).not_to be_valid
    end

    it "requires a discord_uid" do
      expect(build(:user, discord_uid: nil)).not_to be_valid
    end

    it "requires a unique discord_uid" do
      existing = create(:user)
      duplicate = build(:user, discord_uid: existing.discord_uid)

      expect(duplicate).not_to be_valid
    end
  end

  describe "associations" do
    it "has many guilds through user_guilds" do
      user = create(:user)
      guild = create(:guild)
      create(:user_guild, user: user, guild: guild)

      expect(user.guilds).to include(guild)
    end

    it "destroys its posts when destroyed" do
      user = create(:user)
      create(:post, user: user)

      expect { user.destroy }.to change(Post, :count).by(-1)
    end
  end

  describe ".find_or_create_from_omniauth" do
    def auth_hash(uid:, name:, image: nil)
      OmniAuth::AuthHash.new(
        provider: "discord",
        uid: uid,
        info: OmniAuth::AuthHash::InfoHash.new(name: name, image: image)
      )
    end

    it "creates a new user from omniauth data" do
      auth = auth_hash(uid: "111", name: "テストユーザー", image: "https://example.com/a.png")

      expect { User.find_or_create_from_omniauth(auth) }.to change(User, :count).by(1)

      user = User.find_by(discord_uid: "111")
      expect(user.username).to eq("テストユーザー")
      expect(user.avatar_url).to eq("https://example.com/a.png")
    end

    it "finds the existing user instead of creating a duplicate" do
      existing = create(:user, discord_uid: "222")
      auth = auth_hash(uid: "222", name: "別名になっても無視される")

      expect { User.find_or_create_from_omniauth(auth) }.not_to change(User, :count)
      expect(User.find_or_create_from_omniauth(auth)).to eq(existing)
    end
  end

  describe "#sync_guilds_from_discord" do
    it "creates guilds and associates them with the user" do
      user = create(:user)
      guilds_data = [{ "id" => "999", "name" => "テストGuild" }]

      expect { user.sync_guilds_from_discord(guilds_data) }.to change(Guild, :count).by(1)
      expect(user.guilds.reload.pluck(:discord_guild_id)).to include("999")
    end

    it "does not duplicate an existing guild membership" do
      guild = create(:guild, discord_guild_id: "999")
      user = create(:user)
      create(:user_guild, user: user, guild: guild)

      expect {
        user.sync_guilds_from_discord([{ "id" => "999", "name" => guild.name }])
      }.not_to change(UserGuild, :count)
    end
  end
end
