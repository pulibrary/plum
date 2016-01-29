require 'rails_helper'

RSpec.describe HoldingLocationService, vcr: { cassette_name: 'locations' } do
  let(:uri) { 'https://bibdata.princeton.edu/locations/delivery_locations/3' }
  let(:email) { 'ues@princeton.edu' }
  let(:label) { 'Architecture Library' }
  let(:phone) { '609-258-3256' }

  subject { described_class.find(uri) }

  context "rights statements" do
    it "gets the email of a holding location" do
      expect(subject.email).to eq(email)
    end

    it "gets the label of a holding location" do
      expect(subject.label).to eq(label)
    end

    it "gets the phone number of a holding location" do
      expect(subject.phone).to eq(phone)
    end
  end
end
