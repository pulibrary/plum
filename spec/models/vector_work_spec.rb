# Generated via
#  `rails generate geo_concerns:install`
require 'rails_helper'

describe VectorWork do
  xit { is_expected.to be_kind_of(GeoConcerns::VectorWorkBehavior) }

  describe 'thumbnail indexing' do
    let(:vector_work) { FactoryGirl.create(:vector_work) }
    let(:solr_doc) { vector_work.to_solr }
    xit 'calls local thumbnail path service' do
      expect(ThumbnailPathService).to receive(:call).and_return('path').at_least(:once)
      expect(solr_doc['thumbnail_path_ss']).to eq 'path'
    end
  end
end
