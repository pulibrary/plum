require 'rails_helper'

RSpec.describe HoldingLocationRenderer do
  let(:uri) { 'http://rightsstatements.org/vocab/InC/1.0/' }
  let(:obj) {
    {
      label: "Sample",
      phone_number: "123-456-7890",
      contact_email: "ex@example.org",
      url: "https://bibdata.princeton.edu/locations/delivery_locations/1.json",
      id: "https://bibdata.princeton.edu/locations/delivery_locations/1",
      address: "Forrestal Campus Princeton, NJ 08544"
    }
  }
  let(:rendered) { described_class.new(uri).render }

  before do
    allow_any_instance_of(HoldingLocationAuthority).to receive(:find).and_return(obj.stringify_keys)
  end

  context "with a rendered holding location" do
    it "renders the location label and email/phone links" do
      expect(rendered).to include('Sample')
      expect(rendered).to include('ex@example.org')
      expect(rendered).to include('123-456-7890')
      expect(rendered).to include('Forrestal Campus')
    end
  end
end
