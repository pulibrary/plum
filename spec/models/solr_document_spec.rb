require 'rails_helper'

RSpec.describe SolrDocument do
  subject { described_class.new(document_hash) }

  let(:date_created) { "2015-09-02" }
  let(:system_created) { "2015-09-02T12:34:56Z" }
  let(:date_modified) { "2015-10-01T12:34:56Z" }
  let(:document_hash) do
    {
      date_created_tesim: date_created,
      system_modified_dtsi: date_modified,
      system_create_dtsi: system_created,
      language_tesim: ['eng'],
      width_is: 200,
      height_is: 400,
      cartographic_scale_tesim: ['Scale 1:2,000,000'],
      alternative_tesim: ['Alt title 1', 'Alt title 2'],
      contents_tesim: ['Chapter 1', 'Chapter 2'],
      viewing_hint_tesim: ["Viewing Hint"],
      exhibit_id_tesim: ["test"],
      rights_statement_tesim: ["test"],
      rights_note_tesim: ["test"],
      holding_location_tesim: ["test"],
      source_metadata_identifier_tesim: "1",
      source_jsonld_tesim: ["Testing"],
      nav_date_tesim: ["1"],
      portion_note_tesim: ["1"],
      full_text_tesim: ["Text"],
      hasRelatedImage_ssim: ["Image"],
      member_of_collections_ssim: ["Collection1"],
      member_of_collection_ids_ssim: ["1"],
      folder_number_ssim: ["1"]
    }
  end

  describe "#viewing_hint" do
    it "returns the viewing hint" do
      expect(subject.viewing_hint).to eq "Viewing Hint"
    end
  end

  describe "#folder_number" do
    it "returns the first folder numbe" do
      expect(subject.folder_number).to eq "1"
    end
  end

  describe "#collection" do
    it "returns the collection names" do
      expect(subject.collection).to eq ["Collection1"]
    end
  end

  describe "#thumbnail_id" do
    it "returns the thumbnail ID" do
      expect(subject.thumbnail_id).to eq "Image"
    end
  end

  describe "#nav_date" do
    it "returns the nav date" do
      expect(subject.nav_date).to eq ["1"]
    end
  end

  describe "#ocr_text" do
    it "returns the ocr text" do
      expect(subject.ocr_text).to eq "Text"
    end
  end

  describe "#portion_note" do
    it "returns the portion_note" do
      expect(subject.portion_note).to eq ["1"]
    end
  end

  describe "#source_jsonld" do
    it "returns the first source JSONLD" do
      expect(subject.source_jsonld).to eq "Testing"
    end
  end

  describe "#source_metadata_identifier" do
    it "returns the identifier" do
      expect(subject.source_metadata_identifier).to eq "1"
    end
  end

  describe "#rights_statement" do
    it "returns the rights statement" do
      expect(subject.rights_statement).to eq ["test"]
    end
  end

  describe "#rights_note" do
    it "returns the rights note" do
      expect(subject.rights_note).to eq ["test"]
    end
  end

  describe "#holding_location" do
    it "returns the holding location" do
      expect(subject.holding_location).to eq ["test"]
    end
  end

  describe "#exhibit_id" do
    it "returns the exhibit id" do
      expect(subject.exhibit_id).to eq ["test"]
    end
  end

  describe "#create_date" do
    it "returns date_created_tesim" do
      expect(subject.create_date).to eq "09/02/15 12:34:56 PM UTC"
    end
  end

  describe "#date_created" do
    it "returns date_created_tesim" do
      expect(subject.date_created).to eq date_created
    end
  end

  describe "#system_modified" do
    it "has a system modification date" do
      expect(subject.system_modified).to eq('10/01/15 12:34:56 PM UTC')
    end
  end

  describe "#height" do
    it "returns the height_is" do
      expect(subject.height).to eq 400
    end
  end

  describe "#width" do
    it "returns the width_is" do
      expect(subject.width).to eq 200
    end
  end

  describe "#logical_order" do
    it "is an empty hash by default" do
      expect(subject.logical_order).to eq({})
    end
  end

  describe '#ocr_langage' do
    it 'defaults to language if not present' do
      expect(subject['ocr_language_tesim']).to be nil
      expect(subject.language).to eq(['eng'])
      expect(subject.ocr_language).to eq(['eng'])
    end
  end

  describe '#method_missing' do
    it 'passes through to super' do
      expect { subject.send :foo }.to raise_error NoMethodError, /undefined method/
    end
  end

  describe 'document responds to SolrGeoMetadata field methods' do
    it '#cartographic_projection returns nil when field missing' do
      expect(subject.cartographic_projection).to be nil
    end
    it '#cartographic_scale single-valued field returns string' do
      expect(subject.cartographic_scale).to eq 'Scale 1:2,000,000'
    end
    it '#edition returns empty array when field missing' do
      expect(subject.edition).to eq([])
    end
    it '#alternative returns multivalued array' do
      expect(subject.alternative).to eq(['Alt title 1', 'Alt title 2'])
    end
    it '#tableOfContents returns multivalued array' do
      expect(subject.contents).to eq(['Chapter 1', 'Chapter 2'])
    end
  end
end
