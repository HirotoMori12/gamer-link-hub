require "rails_helper"

RSpec.describe PostSearcher do
  let(:guild) { create(:guild) }

  describe "#search" do
    it "returns no posts when the guild is nil" do
      searcher = described_class.new(guild: nil, keyword: "VRChat")

      expect(searcher.search).to be_empty
    end

    it "returns no posts when the keyword is blank" do
      create(:post, guild: guild, body: "VRChatワールドのリンクです")
      searcher = described_class.new(guild: guild, keyword: "")

      expect(searcher.search).to be_empty
    end

    it "matches posts by body" do
      matching = create(:post, guild: guild, body: "VRChatワールドのリンクです")
      non_matching = create(:post, guild: guild, body: "関係ない投稿")

      result = described_class.new(guild: guild, keyword: "VRChat").search

      expect(result).to include(matching)
      expect(result).not_to include(non_matching)
    end

    it "matches posts by tag name" do
      tag = create(:tag, guild: guild, name: "VRChat")
      matching = create(:post, guild: guild, body: "本文にキーワードは含まれない")
      matching.tags << tag

      result = described_class.new(guild: guild, keyword: "VRChat").search

      expect(result).to include(matching)
    end

    it "does not return posts from a different guild" do
      other_guild = create(:guild)
      create(:post, guild: other_guild, body: "VRChat情報")

      result = described_class.new(guild: guild, keyword: "VRChat").search

      expect(result).to be_empty
    end

    it "limits the number of results" do
      3.times { |i| create(:post, guild: guild, body: "VRChat情報 #{i}") }

      result = described_class.new(guild: guild, keyword: "VRChat").search(limit: 2)

      expect(result.size).to eq(2)
    end
  end
end
