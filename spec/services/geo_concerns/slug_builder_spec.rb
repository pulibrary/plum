require 'rails_helper'

describe GeoConcerns::Discovery::DocumentBuilder::SlugBuilder do
  subject { described_class.new(geo_concern_presenter) }

  let(:geo_concern_presenter) { GeoConcerns::VectorWorkShowPresenter.new(SolrDocument.new(geo_concern.to_solr), nil) }
  let(:geo_concern) { FactoryGirl.build(:vector_work, attributes) }
  let(:attributes) { { id: 'geo-work-1',
                       title: ['Geo Work'],
                       description: ['This is a Geo Work'],
                       creator: ['Yosiwo George'],
                       publisher: ['National Geographic'],
                       spatial: ['Micronesia'],
                       temporal: ['2011'],
                       subject: ['Human settlements'],
                       language: ['Esperanto'],
                       identifier: 'ark:/99999/fk4'
                     }
  }

  describe 'vector work slug' do
    it 'uses ark noid fowlling the provenance' do
      document = instance_double('Document')
      expect(document).to receive(:slug=).with('princeton-university-library-fk4')
      subject.build(document)
    end
  end
end
