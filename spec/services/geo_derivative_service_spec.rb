require 'rails_helper'
require 'hyrax/specs/shared_specs'

RSpec.describe GeoDerivativesService do
  let(:valid_file_set) do
    FileSet.new.tap do |f|
      allow(f).to receive(:geo_mime_type).and_return("application/vnd.geo+json")
    end
  end
  let(:invalid_file_set) do
    FileSet.new
  end

  subject { described_class.new(file_set) }

  it_behaves_like "a Hyrax::DerivativeService"
end
