require 'rails_helper'

describe PairtreeDerivativePath do
  let(:plum_config) { { geo_derivatives_path: 'geo-derivatives' } }

  before do
    allow(Hyrax.config).to receive(:derivatives_path).and_return('tmp')
    allow(Plum).to receive(:config).and_return(plum_config)
  end

  describe '.derivative_path_for_reference' do
    subject { described_class.derivative_path_for_reference(object, destination_name) }

    let(:object) { double(id: '08612n57q') }
    let(:destination_name) { 'thumbnail' }

    it { is_expected.to eq 'tmp/08/61/2n/57/q-thumbnail.jpeg' }
    context "when given an intermediate file" do
      let(:destination_name) { 'intermediate_file' }

      it { is_expected.to eq 'tmp/08/61/2n/57/q-intermediate_file.jp2' }
    end
    context "when given an unrecognized file" do
      let(:destination_name) { 'unrecognized' }

      it { is_expected.to eq 'tmp/08/61/2n/57/q-unrecognized.unrecognized' }
    end
    context "when given ocr" do
      let(:destination_name) { 'ocr' }

      it { is_expected.to eq 'tmp/08/61/2n/57/q-ocr.hocr' }
    end
    context "when given a PDF" do
      context "which is color" do
        let(:destination_name) { 'color-pdf' }
        it "returns a unique PDF path based on the resource identifier" do
          identifier = instance_double(ResourceIdentifier)
          allow(ResourceIdentifier).to receive(:new).with(object.id).and_return(identifier)
          allow(identifier).to receive(:to_s).and_return("banana")

          expect(subject).to eql "tmp/08/61/2n/57/q-banana-color-pdf.pdf"
        end
      end
      context "which is gray" do
        let(:destination_name) { 'gray-pdf' }
        it "returns a unique PDF path based on the resource identifier" do
          identifier = instance_double(ResourceIdentifier)
          allow(ResourceIdentifier).to receive(:new).with(object.id).and_return(identifier)
          allow(identifier).to receive(:to_s).and_return("banana")

          expect(subject).to eql "tmp/08/61/2n/57/q-banana-gray-pdf.pdf"
        end
      end
    end
    context 'when given a display raster' do
      let(:destination_name) { 'display_raster' }
      it { is_expected.to eq 'tmp/08/61/2n/57/q-display_raster.tif' }
    end
    context 'when given a display vector' do
      let(:destination_name) { 'display_vector' }
      it { is_expected.to eq 'tmp/08/61/2n/57/q-display_vector.zip' }
    end
    context 'when given a geo file set' do
      let(:object) { double(id: '08612n57q', geo_mime_type: 'application/vnd.geo+json') }
      it { is_expected.to eq 'geo-derivatives/08/61/2n/57/q-thumbnail.jpeg' }
    end
  end
end
