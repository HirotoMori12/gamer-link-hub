require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#discord_bot_install_url" do
    it "builds an OAuth2 bot install URL with the bot and applications.commands scopes" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("DISCORD_CLIENT_ID").and_return("client123")

      url = helper.discord_bot_install_url

      expect(url).to eq("https://discord.com/api/oauth2/authorize?client_id=client123&scope=bot%20applications.commands&permissions=0")
    end
  end
end
