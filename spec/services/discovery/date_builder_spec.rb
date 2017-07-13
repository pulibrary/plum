require 'rails_helper'

describe Discovery::DateBuilder do
  subject { described_class.new(geo_work_presenter) }

  let(:document) { instance_double('Document') }
  let(:geo_work_presenter) { VectorWorkShowPresenter.new(SolrDocument.new(geo_work.to_solr), nil) }

  describe 'geospatial work document' do
    before do
      allow(document).to receive(:layer_modified=)
      allow(document).to receive(:issued=)
    end

    context 'with temporal values' do
      let(:geo_work) { FactoryGirl.build(:vector_work, temporal: ['1985']) }

      it 'builds the layer year from the temporal attribute' do
        expect(document).to receive(:layer_year=).with(1985)
        subject.build(document)
      end
    end

    context 'with date values' do
      let(:geo_work) { FactoryGirl.build(:vector_work, date: ['1969']) }

      it 'builds the layer year from the date attribute' do
        expect(document).to receive(:layer_year=).with(1969)
        subject.build(document)
      end
    end
  end
end
