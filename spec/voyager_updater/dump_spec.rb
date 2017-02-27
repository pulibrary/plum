require 'rails_helper'

RSpec.describe VoyagerUpdater::Dump, vcr: { cassette_name: "voyager_dump" }do
  subject { described_class.new(dump_url) }
  let(:dump_url) { "https://bibdata.princeton.edu/dumps/1081.json" }

  describe "update_ids" do
    it "returns all update IDs" do
      expect(subject.update_ids).to eq ["359850", "422712", "567735"]
    end
  end

  describe "#create_ids" do
    it "returns all the created IDs" do
      expect(subject.create_ids).to eq ["9567836", "9567837", "9567838"]
    end
  end

  describe "#ids_needing_updated" do
    context "when there are no records" do
      it "returns an empty array" do
        expect(subject.ids_needing_updated).to eq []
      end
    end
    context "when there are records with a matching source metadata identifier" do
      it "returns their record IDs" do
        s = FactoryGirl.create(:scanned_resource, source_metadata_identifier: "359850")
        s2 = FactoryGirl.create(:scanned_resource, source_metadata_identifier: "9567836")
        expect(subject.ids_needing_updated).to contain_exactly s.id, s2.id
      end
    end
  end
end
