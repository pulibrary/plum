# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AuthToken, type: :model do
  it "creates a token on create" do
    expect(described_class.create.token).not_to be_blank
  end

  it "serializes the groups the token grants" do
    token = described_class.create(groups: ["admin"])
    expect(token.reload.groups).to eq ["admin"]
  end

  it "strips blanks when setting groups" do
    token = described_class.create(groups: ["admin", ""])
    expect(token.reload.groups).to eq ["admin"]
  end
end
