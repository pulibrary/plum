require 'rails_helper'

RSpec.describe CicognaraCSV do
  describe "#headers" do
    let(:headers) { ['digital_cico_number', 'label', 'manifest', 'contributing_library', 'owner_call_number',
                     'owner_system_number', 'other_number', 'version_edition_statement',
                     'version_publication_statement', 'version_publication_date', 'additional_responsibility',
                     'provenance', 'physical_characteristics', 'rights', 'based_on_original'] }

    it 'has a list of headers' do
      expect(described_class.headers).to eq(headers)
    end
  end

  describe "#values", vcr: { cassette_name: "cicognara" } do
    let!(:obj) do
      obj = FactoryGirl.create :complete_scanned_resource_in_collection, source_metadata_identifier: '2068747'
      obj.apply_remote_metadata
      obj.save!
      obj
    end
    before do
    end
    let(:col) { obj.member_of_collections.first }
    let(:manifest_url) { "http://plum.com/concern/scanned_resources/#{obj.id}/manifest" }
    let(:values) { [['cico:qgb', 'Plum', manifest_url, 'Princeton University Library',
                     'Oversize NA2810 .H75f', '2068747', nil, nil, 'Amsterdam, J. Jeansson, 1620.', '1620',
                     nil, nil, '39 . 30 plates. 30 x 40 cm.', 'http://rightsstatements.org/vocab/NKC/1.0/',
                     false]] }

    it 'has values' do
      expect(described_class.values(col)).to eq(values)
    end
  end
end
