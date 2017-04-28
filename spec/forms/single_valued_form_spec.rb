require 'rails_helper'

RSpec.describe SingleValuedForm do
  subject { TestForm.new(work, nil, nil) }
  let(:work) { FactoryGirl.build :ephemera_box }

  before do
    class TestForm < Hyrax::Forms::WorkForm
      include SingleValuedForm
    end
    TestForm.single_valued_fields = [:identifier]
    TestForm.model_class = ::EphemeraBox
    TestForm.terms = [:identifier, :title]
  end

  after do
    Object.send(:remove_const, :TestForm)
  end

  context "an instance" do
    it "reports single-valued fields" do
      expect(subject.multiple?(:identifier)).to be false
      expect(subject.multiple?(:title)).to be true
    end
  end

  context "the class" do
    it "reports single-valued fields" do
      expect(TestForm.multiple?(:identifier)).to be false
      expect(TestForm.multiple?(:title)).to be true
    end
  end

  describe "model_attributes" do
    let(:params) { ActionController::Parameters.new(identifier: '123', title: ['Box 1']) }
    let(:attribs) { TestForm.model_attributes(params).to_h }

    it "converts singular fields to arrays" do
      expect(attribs[:identifier]).to eq(['123'])
      expect(attribs[:title]).to eq(['Box 1'])
    end
  end
end
