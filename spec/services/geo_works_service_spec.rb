require 'rails_helper'

RSpec.describe GeoWorksService do
  subject { described_class.new(work) }

  describe '#geo_work?' do
    context 'with a vector work' do
      let(:work) { VectorWork.new }

      it 'returns true' do
        expect(subject.geo_work?).to be true
      end
    end

    context 'with a scanned resource' do
      let(:work) { ScannedResource.new }

      it 'returns false' do
        expect(subject.geo_work?).to be false
      end
    end

    context 'with a map set solr document dummy model' do
      let(:map_set) { MapSet.new }
      let(:document) do
        MapSetShowPresenter.new(
          SolrDocument.new(
            map_set.to_solr
          ), nil
        )
      end
      let(:work) { document.to_model }

      it 'returns true' do
        expect(subject.geo_work?).to be true
      end
    end
  end
end
