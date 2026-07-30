require "rails_helper"

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  it "requires a unique discord_uid" do
    existing = create(:user)
    duplicate = build(:user, discord_uid: existing.discord_uid)

    expect(duplicate).not_to be_valid
  end
end
