require 'rails_helper'

RSpec.describe SingleValuedForm do
  subject { described_class.new(work, nil, nil) }
  let(:work) { FactoryGirl.build :ephemera_box }

  before do
    described_class.single_valued_fields = [:barcode]
    described_class.model_class = ::EphemeraBox
    described_class.terms = [:barcode, :title]
  end

  context "an instance" do
    it "reports single-valued fields" do
      expect(subject.multiple?(:barcode)).to be false
      expect(subject.multiple?(:title)).to be true
    end
  end

  context "the class" do
    it "reports single-valued fields" do
      expect(described_class.multiple?(:barcode)).to be false
      expect(described_class.multiple?(:title)).to be true
    end
  end

  describe "model_attributes" do
    let(:params) { ActionController::Parameters.new(barcode: '123', title: ['Box 1']) }
    let(:attribs) { described_class.model_attributes(params).to_h }

    it "converts singular fields to arrays" do
      expect(attribs[:barcode]).to eq(['123'])
      expect(attribs[:title]).to eq(['Box 1'])
    end
  end
end
