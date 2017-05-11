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

  describe "#cleanup_derivatives" do
    let(:tmpfile) { Tempfile.new }
    let(:factory) { class_double('PairtreeDerivativePath') }
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
