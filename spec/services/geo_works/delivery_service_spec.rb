require 'rails_helper'

describe GeoWorks::DeliveryService do
  let(:path) { 'path-to-display-copy' }
  let(:file_set) { instance_double("FileSet") }

  describe '#initialize' do
    it 'calls local geoserver service' do
      expect(Geoserver).to receive(:new)
      described_class.new(file_set, path)
    end
  end
end
