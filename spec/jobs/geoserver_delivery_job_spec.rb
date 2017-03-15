require 'rails_helper'

describe GeoserverDeliveryJob do
  let(:id) { 'ab' }
  let(:file_set) { instance_double(FileSet, id: id, geo_mime_type: file_format) }

  before do
    allow(subject).to receive(:file_set).and_return(file_set)
  end

  describe '#content_url' do
    context 'with a vector file' do
      let(:file_format) { 'application/zip; ogr-format="ESRI Shapefile"' }
      it 'returns a path to the vector file' do
        expect(subject.content_url).to include('ab-display_vector.zip')
      end
    end

    context 'with a raster file' do
      let(:file_format) { 'image/tiff; gdal-format=GTiff' }
      it 'returns a path to the raster file' do
        expect(subject.content_url).to include('ab-display_raster.tif')
      end
    end

    context 'with a non-geospatial file' do
      let(:file_format) { 'image/jpeg' }
      it 'returns an empty path' do
        expect(subject.content_url).to eq('')
      end
    end
  end
end
