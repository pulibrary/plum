# frozen_string_literal: true
require 'rails_helper'

describe VectorWork do
  it { is_expected.to be_kind_of(GeoWorks::VectorWorkBehavior) }

  describe 'thumbnail indexing' do
    let(:vector_work) { FactoryGirl.create(:vector_work) }
    let(:solr_doc) { vector_work.to_solr }
    it 'calls local thumbnail path service' do
      expect(ThumbnailPathService).to receive(:call).and_return('path').at_least(:once)
      expect(solr_doc['thumbnail_path_ss']).to eq 'path'
    end
  end

  describe 'populate_metadata' do
    subject { FactoryGirl.create(:vector_work_with_metadata_file) }
    let(:external_metadata_file) { subject.metadata_files.first }
    let(:doc) { Nokogiri::XML(fixture('zipcodes_fgdc.xml')) }

    before do
      allow(external_metadata_file).to receive(:metadata_xml) { doc }
    end

    it 'only extracts official ISO topic categories' do
      subject.populate_metadata(external_metadata_file.id)
      expect(subject.subject).to include('Location')
      expect(subject.subject).to include('Society')
      expect(subject.subject).not_to include('polygon')
    end
  end
end
