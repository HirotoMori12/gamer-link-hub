require "rails_helper"

RSpec.describe Discord::ApiClient do
  let(:client) { described_class.new(application_id: "app123", bot_token: "tok456") }

  def stub_http(code: "200", body: "{}")
    response = instance_double(Net::HTTPResponse, code: code, body: body)
    http = instance_double(Net::HTTP, request: response)
    allow(Net::HTTP).to receive(:start).and_yield(http)
    http
  end

  describe "#register_global_commands" do
    it "PUTs commands to the global commands endpoint with bot auth" do
      http = stub_http(body: '[{"id":"1","name":"search"}]')

      client.register_global_commands([{ name: "search", type: 1 }])

      expect(http).to have_received(:request) do |request|
        expect(request.method).to eq("PUT")
        expect(request.uri.to_s).to eq("https://discord.com/api/v10/applications/app123/commands")
        expect(request["Authorization"]).to eq("Bot tok456")
      end
    end

    it "sends the commands as the request body and returns the parsed response" do
      http = stub_http(body: '[{"id":"1","name":"search"}]')

      result = client.register_global_commands([{ name: "search", type: 1 }])

      expect(http).to have_received(:request) do |request|
        expect(JSON.parse(request.body)).to eq([{ "name" => "search", "type" => 1 }])
      end
      expect(result).to eq([{ "id" => "1", "name" => "search" }])
    end
  end

  describe "#list_global_commands" do
    it "GETs the global commands endpoint with bot auth" do
      http = stub_http(body: "[]")

      client.list_global_commands

      expect(http).to have_received(:request) do |request|
        expect(request.method).to eq("GET")
        expect(request.uri.to_s).to eq("https://discord.com/api/v10/applications/app123/commands")
        expect(request["Authorization"]).to eq("Bot tok456")
      end
    end
  end

  describe "#clear_global_commands" do
    it "PUTs an empty array to the global commands endpoint" do
      http = stub_http(body: "[]")

      client.clear_global_commands

      expect(http).to have_received(:request) do |request|
        expect(request.method).to eq("PUT")
        expect(request.body).to eq("[]")
      end
    end
  end

  describe "#register_guild_commands" do
    it "PUTs commands to the guild-scoped commands endpoint" do
      http = stub_http(body: '[{"id":"1"}]')

      client.register_guild_commands("guild999", [{ name: "search", type: 1 }])

      expect(http).to have_received(:request) do |request|
        expect(request.method).to eq("PUT")
        expect(request.uri.to_s).to eq("https://discord.com/api/v10/applications/app123/guilds/guild999/commands")
        expect(request["Authorization"]).to eq("Bot tok456")
      end
    end
  end

  describe "#list_guild_commands" do
    it "GETs the guild-scoped commands endpoint" do
      http = stub_http(body: "[]")

      client.list_guild_commands("guild999")

      expect(http).to have_received(:request) do |request|
        expect(request.method).to eq("GET")
        expect(request.uri.to_s).to eq("https://discord.com/api/v10/applications/app123/guilds/guild999/commands")
      end
    end
  end

  describe "#clear_guild_commands" do
    it "PUTs an empty array to the guild-scoped commands endpoint" do
      http = stub_http(body: "[]")

      client.clear_guild_commands("guild999")

      expect(http).to have_received(:request) do |request|
        expect(request.method).to eq("PUT")
        expect(request.uri.to_s).to eq("https://discord.com/api/v10/applications/app123/guilds/guild999/commands")
        expect(request.body).to eq("[]")
      end
    end
  end

  describe "#fetch_user_guilds" do
    it "GETs the user guilds endpoint with a bearer token (not bot auth)" do
      http = stub_http(body: '[{"id":"1","name":"MyGuild"}]')

      result = client.fetch_user_guilds("user-access-token")

      expect(http).to have_received(:request) do |request|
        expect(request["Authorization"]).to eq("Bearer user-access-token")
      end
      expect(result).to eq([{ "id" => "1", "name" => "MyGuild" }])
    end
  end

  describe "error handling" do
    it "returns nil and logs when the response is not 2xx" do
      stub_http(code: "401", body: "unauthorized")
      allow(Rails.logger).to receive(:error)

      expect(client.list_global_commands).to be_nil
      expect(Rails.logger).to have_received(:error).at_least(:once)
    end

    it "returns nil and logs when the request raises" do
      allow(Net::HTTP).to receive(:start).and_raise(SocketError, "connection failed")
      allow(Rails.logger).to receive(:error)

      expect(client.list_global_commands).to be_nil
      expect(Rails.logger).to have_received(:error).at_least(:once)
    end
  end
end
