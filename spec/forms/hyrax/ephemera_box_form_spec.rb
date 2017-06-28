require 'rails_helper'

RSpec.describe Hyrax::EphemeraBoxForm do
  subject { described_class.new(work, nil, nil) }
  let(:work) { EphemeraBox.new }

  it "wants barcode autofocus" do
    expect(subject.autofocus_barcode?).to be true
  end

  describe "#primary_terms" do
    it "has primary terms" do
      expect(subject.primary_terms).to include :shipped_date, :tracking_number
    end
  end
end
