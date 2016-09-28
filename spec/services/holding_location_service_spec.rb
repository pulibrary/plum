require 'rails_helper'

RSpec.describe HoldingLocationService do
  let(:uri) { 'https://libraries.indiana.edu/music' }
  let(:email) { 'libmus@indiana.edu' }
  let(:label) { 'William & Gayle Cook Music Library' }
  let(:phone) { '(812) 855-2970' }

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
