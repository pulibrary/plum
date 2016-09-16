require 'rails_helper'

RSpec.describe HoldingLocationAuthority do
  subject { described_class.new }
  let(:id) { 'https://bibdata.princeton.edu/locations/delivery_locations/3' }
  let(:obj) {
    { 
      "label" => "Architecture Library",
      "address" => "School of Architecture Building, Second Floor Princeton, NJ 08544",
      "phone_number" => "609-258-3256",
      "contact_email" => "ues@princeton.edu",
      "gfa_pickup" => "PW",
      "staff_only" => false,
      "pickup_location" => true,
      "digital_location" => true,
      "url" => "https://bibdata.princeton.edu/locations/delivery_locations/3.json",
      "library" => {"label" => "Architecture Library", "code" => "architecture"},
      "id" => "https://bibdata.princeton.edu/locations/delivery_locations/3"
    }
  }
  context "with data" do
    it "finds a holding location by id" do
      expect(subject.find(id)).to eq(obj.stringify_keys)
    end

    it "lists all of the holding locations" do
      expect(subject.all.length).to eq(11)
      expect(subject.all).to include(obj.stringify_keys)
    end
  end
end
