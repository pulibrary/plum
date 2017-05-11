require 'rails_helper'
require 'hyrax/specs/shared_specs'

RSpec.describe ScannedMapDerivativesService do
  let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:parent) { instance_double(ImageWork, visibility: visibility) }
  let(:valid_file_set) do
    FileSet.new.tap do |f|
      allow(f).to receive(:mime_type_storage).and_return(["image/tiff"])
      allow(f).to receive(:geo_mime_type).and_return("image/tiff")
      allow(f).to receive(:parent).and_return(parent)
    end
  end
  let(:invalid_file_set) do
    FileSet.new
  end
  let(:file_set) { valid_file_set }
  subject { described_class.new(file_set) }

  it_behaves_like "a Hyrax::DerivativeService"

  describe '#create_derivatives' do
    before do
      allow(subject).to receive(:derivative_url).and_return('path')
    end

    context 'with a public parent work' do
      it 'creates a thumbnail and a JP2K derivative' do
        expect(Hydra::Derivatives::ImageDerivatives).to receive(:create)
        expect(Hydra::Derivatives::Jpeg2kImageDerivatives).to receive(:create)
        expect(RunOCRJob).to receive(:perform_later)
        subject.create_derivatives('path')
      end
    end

    context 'with a private parent work' do
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
      it 'creates a thumbnail but not a JP2K derivative' do
        expect(Hydra::Derivatives::ImageDerivatives).to receive(:create)
        expect(Hydra::Derivatives::Jpeg2kImageDerivatives).not_to receive(:create)
        expect(RunOCRJob).to receive(:perform_later)
        subject.create_derivatives('path')
      end
    end
  end

  describe "#cleanup_derivatives" do
    let(:tmpfile) { Tempfile.new }
    let(:factory) { class_double(PairtreeDerivativePath) }
    before do
      allow(subject).to receive(:derivative_path_factory).and_return(factory)
      allow(factory).to receive(:derivatives_for_reference).and_return(tmpfile)
    end

    it "removes the files" do
      subject.cleanup_derivatives
      expect(File.exist?(tmpfile.path)).to be true
    end
  end
end
