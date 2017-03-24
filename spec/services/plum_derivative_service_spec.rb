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
end
