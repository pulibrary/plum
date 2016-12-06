require 'rails_helper'

RSpec.describe IuMetadata::VariationsRecord do
  let(:record1_path) { Rails.root.join("spec", "fixtures", "variations_xml", "bhr9405.xml") }
  let(:record1) { described_class.new(record1_path, open(record1_path)) }
  let(:record1_xml) { File.open(record1_path) { |f| Nokogiri::XML(f) } }
  let(:file1) { record1_xml.xpath('//FileInfos/FileInfo').first }

  describe "parses attributes" do
    { source_metadata_identifier: 'BHR9405',
      viewing_hint: 'paged',
      location: 'IU Music Library',
      holding_location: 'https://libraries.indiana.edu/music',
      physical_description: '1 score (64 p.) ; 32 cm',
      copyright_holder: ['G. Ricordi & Co.'],
      visibility: 'open',
      rights_statement: 'http://rightsstatements.org/vocab/InC/1.0/',
      collections: []
    }.each do |att, val|
      describe "##{att}" do
        it "retrieves the correct value" do
          expect(record1.send(att)).to eq val
        end
      end
    end
  end

  describe "#filename" do
    let(:raw_filename) { file1.xpath('FileName').first&.content.to_s }
    let(:normalized_filename) { record1.send(:filename, file1) }
    let(:raw_pagenum) { '1.djvu' }
    let(:pagenum_xml) { "<FileName>#{raw_pagenum}</FileName>" }
    let(:normalized_pagenum) { record1.send(:filename, Nokogiri::XML(pagenum_xml)) }
    let(:raw_display) { 'bhr9405-1-1-display.djvu' }
    let(:display_xml) { "<FileName>#{raw_display}</FileName>" }
    let(:normalized_display) { record1.send(:filename, Nokogiri::XML(pagenum_xml)) }
    it "normalizes volume, pagenum components" do
      expect(raw_filename).to match(/[a-z]{3}\d{4}-\d{2}-\d{1}/)
      expect(normalized_filename).to match(/[a-z]{3}\d{4}-\d{1}-\d{4}/)
    end
    it "replaces the filename extension" do
      expect(raw_filename).to match(/\.djvu$/)
      expect(normalized_filename).to match(/\.tif$/)
    end
    it "normalizes a pagenum-only filename" do
      expect(raw_pagenum).to match(/^\d\.djvu$/)
      expect(normalized_pagenum).to match(/[a-z]{3}\d{4}-\d{1}-\d{4}/)
    end
    it "normalizes a display-suffixed filename" do
      expect(raw_display).to match(/display/)
      expect(normalized_display).to match(/^[a-z]{3}\d{4}-\d{1}-\d{4}.tif$/)
    end
  end
end
