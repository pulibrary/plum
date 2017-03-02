require 'rails_helper'
require 'hyrax/specs/shared_specs'

RSpec.describe PlumDerivativesService do
  let(:valid_file_set) do
    FileSet.new.tap do |f|
      allow(f).to receive(:mime_type_storage).and_return(["image/tiff"])
    end
  end
  let(:invalid_file_set) do
    FileSet.new
  end
  let(:file_set) { valid_file_set }
  subject { described_class.new(file_set) }

  it_behaves_like "a Hyrax::DerivativeService"

  describe "#valid?" do
    context "when it's replacing a pudl:images" do
      let(:file_set) do
        valid_file_set.tap do |f|
          allow(f).to receive(:replaces).and_return("urn:pudl:images:test")
        end
      end
      it "returns false" do
        expect(subject).not_to be_valid
      end
    end
  end

  describe "#recipe" do
    context "with a non-map tiff" do
      it "uses the default recipe" do
        expect(subject.send(:recipe)).to eq(:default)
      end
    end

    context "with a map tiff" do
      before do
        allow(file_set).to receive(:geo_mime_type).and_return "image/tiff"
      end

      it "uses the geo recipe" do
        expect(subject.send(:recipe)).to eq(:geo)
      end
    end
  end
end
