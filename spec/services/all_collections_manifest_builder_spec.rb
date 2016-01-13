require 'rails_helper'

RSpec.describe AllCollectionsManifestBuilder do
  subject { described_class.new }
  context "when there are collections" do
    let(:manifest_json) { JSON.parse(subject.to_json) }
    it "builds them as sub-manifests" do
      FactoryGirl.create(:collection)

      expect(manifest_json["manifests"].length).to eq 1
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
