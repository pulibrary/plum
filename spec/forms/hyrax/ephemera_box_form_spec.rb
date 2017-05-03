require 'rails_helper'

RSpec.describe Hyrax::EphemeraBoxForm do
  subject { described_class.new(work, nil, nil) }
  let(:work) { EphemeraBox.new }

  it "wants barcode autofocus" do
    expect(subject.autofocus_barcode?).to be true
  end
end
