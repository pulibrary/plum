require 'rails_helper'

RSpec.describe VariationsDocument do
  let(:record1_path) { Rails.root.join("spec", "fixtures", "variations_xml", "bhr9405.xml") }
  let(:record1) { described_class.new(record1_path) }
  let(:record1_xml) { File.open(record1_path) { |f| Nokogiri::XML(f) } }
  let(:file1) { record1_xml.xpath('//FileInfos/FileInfo').first }

  describe "parses attributes" do
    { source_metadata_identifier: 'BHR9405',
      viewing_direction: 'left-to-right',
      location: 'IU Music Library',
      holding_location: 'https://libraries.indiana.edu/music',
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
    it "normalizes volume, pagenum components" do
      expect(raw_filename).to match(/[a-z]{3}\d{4}-\d{1}-\d{1}/)
      expect(normalized_filename).to match(/[a-z]{3}\d{4}-\d{1}-\d{4}/)
    end
    it "replaces the filename extension" do
      expect(raw_filename).to match(/\.djvu$/)
      expect(normalized_filename).to match(/\.tif$/)
    end
  end
end
