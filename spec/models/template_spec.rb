# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Template, type: :model do
  describe "#params" do
    it "serializes to a hash and back" do
      t = described_class.new
      t.params = { "title" => "test" }
      t.save
      expect(t.reload.params["title"]).to eq "test"
    end
  end
end
