require 'rails_helper'

RSpec.describe MapSetShowPresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:ability) { nil }

  subject { described_class.new(solr_document, ability) }

  describe 'file presenters' do
    let(:obj) { FactoryGirl.create(:map_set_with_metadata_file) }
    let(:attributes) { obj.to_solr }

    describe '#external_metadata_file_set_presenters' do
      it 'returns only external_metadata_file_set_presenters' do
        expect(subject.external_metadata_file_set_presenters.count).to eq 1
      end
    end
  end
end
