require 'rails_helper'

describe GeoConcerns::Discovery::DocumentBuilder::SlugBuilder do
  subject { described_class.new(geo_concern_presenter) }

  let(:document) { instance_double('Document') }
  let(:plum_config) { { geoblacklight_provenance: 'Princeton' } }
  let(:geo_concern_presenter) { GeoConcerns::VectorWorkShowPresenter.new(SolrDocument.new(geo_concern.to_solr), nil) }
  let(:geo_concern) { FactoryGirl.build(:vector_work, identifier: 'ark:/99999/fk4') }

  before do
    allow(Plum).to receive(:config).and_return(plum_config)
  end

  describe 'vector work document' do
    it 'creates a slug with an ark noid and uses a locally configured provenance' do
      expect(document).to receive(:provenance=).with('Princeton')
      expect(document).to receive(:slug=).with('princeton-fk4')
      subject.build(document)
    end
  end
end
