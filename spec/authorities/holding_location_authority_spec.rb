require 'rails_helper'

RSpec.describe HoldingLocationAuthority do
  subject { described_class.new }
  let(:id) { 'https://libraries.indiana.edu/music' }
  let(:obj) {
    {
      "label" => "William & Gayle Cook Music Library",
      "address" => "200 South Jordan Ave",
      "phone_number" => "(812) 855-2970",
      "contact_email" => "libmus@indiana.edu",
      "gfa_pickup" => "PW",
      "staff_only" => false,
      "pickup_location" => true,
      "digital_location" => true,
      "url" => "https://libraries.indiana.edu/music",
      "library" => { "label" => "William & Gayle Gook Music Library", "code" => "libmus" },
      "id" => "https://libraries.indiana.edu/music"
    }
  }
  context "with data" do
    it "finds a holding location by id" do
      expect(subject.find(id)).to eq(obj.stringify_keys)
    end

    it "lists all of the holding locations" do
      expect(subject.all.length).to eq(1)
      expect(subject.all).to include(obj.stringify_keys)
    end
  end
end
