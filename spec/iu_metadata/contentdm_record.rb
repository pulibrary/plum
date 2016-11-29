require 'rails_helper'

RSpec.describe IuMetadata::ContentdmRecord do
  let(:fixture_path) { File.expand_path('../../fixtures', __FILE__) }
  let(:record1) {
    pth = File.join(fixture_path, 'contentdm_xml/Irish_People.xml')
    described_class.new('file://' + pth, open(pth))
  }
  record1_attributes =
    { source_metadata_identifier: 'Irish People &lt;br&gt; http://indiamond6.ulib.iupui.edu/cdm/search/collection/IP',
      viewing_direction: 'left-to-right'
    }

  describe "#attributes" do
    it "provides attibutes" do
      expect(record1.attributes).to eq record1_attributes
    end
  end

  describe "parses attributes" do
    record1_attributes.each do |att, val|
      describe "##{att}" do
        it "retrieves the correct value" do
          expect(record1.send(att)).to eq val
        end
      end
    end
  end
end
