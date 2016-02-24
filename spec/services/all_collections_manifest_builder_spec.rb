require 'rails_helper'

RSpec.describe AllCollectionsManifestBuilder do
  subject { described_class.new }
  context "when there are collections" do
    let(:manifest_json) { JSON.parse(subject.to_json) }
    it "builds them as sub-collections" do
      FactoryGirl.create(:collection)

      expect(manifest_json["collections"].length).to eq 1
      expect(manifest_json["collections"].first["metadata"]).not_to be_blank
    end
    it "doesn't populate manifests" do
      FactoryGirl.create(:collection)

      expect(manifest_json["manifests"]).to be_nil
    end
    it "doesn't generate a viewingHint or viewingDirection" do
      expect(manifest_json["viewingHint"]).to be_nil
      expect(manifest_json["viewingDirection"]).to be_nil
    end
    it "has an ID" do
      expect(manifest_json["@id"]).to eq "http://plum.com/collections/manifest"
    end
    context "when SSL is set" do
      subject { described_class.new(nil, ssl: true) }
      it "can have an SSL ID" do
        expect(manifest_json["@id"]).to eq "https://plum.com/collections/manifest"
      end
    end
  end
end
