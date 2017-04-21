require 'rails_helper'

RSpec.describe BarcodeAttributeRenderer do
  subject { described_class.new('identifier', '123') }

  it "uses 'Barcode' for the label" do
    expect(subject.label).to eq('Barcode')
  end
end
