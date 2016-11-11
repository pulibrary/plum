require 'rails_helper'

RSpec.describe VariationsDocument do
  let(:fixture_path) { File.expand_path('../../fixtures', __FILE__) }
  let(:record1) {
    pth = File.join(fixture_path, 'variations_xml/bhr9405.xml')
    described_class.new(pth)
  }
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
end
