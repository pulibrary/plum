require 'rails_helper'

RSpec.describe HoldingLocationAuthority do
  subject { described_class.new }
  let(:json) {
    '[{
      "label":"Plasma Physics Library",
      "phone_number":"609-243-3565",
      "contact_email":"ppllib@princeton.edu",
      "url":"https://bibdata.princeton.edu/locations/delivery_locations/1.json"
    },{
      "label":"Architecture Library",
      "phone_number":"609-258-3256",
      "contact_email":"ues@princeton.edu",
      "url":"https://bibdata.princeton.edu/locations/delivery_locations/3.json"
    }]'
  }
  let(:id) { 'https://bibdata.princeton.edu/locations/delivery_locations/3' }
  let(:obj) {
    {
      label: "Architecture Library",
      phone_number: "609-258-3256",
      contact_email: "ues@princeton.edu",
      url: "https://bibdata.princeton.edu/locations/delivery_locations/3.json",
      id: "https://bibdata.princeton.edu/locations/delivery_locations/3"
    }
  }

  before do
    allow(RestClient).to receive(:get).and_return(json)
  end

  context "with data" do
    it "finds a holding location by id" do
      expect(subject.find(id)).to eq(obj.stringify_keys)
    end

    it "lists all of the holding locations" do
      expect(subject.all.length).to eq(2)
      expect(subject.all).to include(obj.stringify_keys)
    end
  end
end
