require 'rails_helper'

RSpec.describe IuMetadata::METSRecord do
  let(:fixture_path) { File.expand_path('../../fixtures', __FILE__) }
  let(:record1) {
    pth = File.join(fixture_path, 'pudl_mets/pudl0001-4609321-s42.mets')
    described_class.new('file://' + pth, open(pth))
  }
  record1_attributes =
    { source_metadata_identifier: 'bhr9405',
      identifier: 'ark:/88435/7d278t10z',
      replaces: 'pudl0001/4609321/s42',
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
