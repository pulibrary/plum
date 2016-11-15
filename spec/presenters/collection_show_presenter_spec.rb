require 'rails_helper'

RSpec.describe CollectionShowPresenter do
  subject { described_class.new(solr_doc, nil) }
  let(:solr_doc) { SolrDocument.new(doc) }
  let(:collection) { FactoryGirl.build(:collection, id: "collection") }
  let(:doc) do
    allow(collection).to receive(:new_record?).and_return(false)
    collection.to_solr
  end
  let(:scanned_resource) do
    s = FactoryGirl.build(:scanned_resource)
    s.member_of_collections = [collection]
    allow(s).to receive(:id).and_return("resource")
    solr.add(s.to_solr)
    s
  end
  let(:solr) { ActiveFedora.solr.conn }
  before do
    doc
    scanned_resource
    solr.commit
  end

  describe "#member_presenters" do
    it "returns presenters for each Scanned Resource" do
      expect(subject.member_presenters.map(&:id)).to eq [scanned_resource.id]
    end
  end

  describe "#logical_order" do
    it "returns an empty hash" do
      expect(subject.logical_order).to eq({})
    end
  end

  describe "#viewing_hint" do
    it "is always nil" do
      expect(subject.viewing_hint).to eq nil
    end
  end

  it "can be used to create a manifest" do
    manifest = nil
    expect { manifest = ManifestBuilder.new(subject).to_json }.not_to raise_error
    json_manifest = JSON.parse(manifest)
    expect(json_manifest['viewingHint']).not_to eq "multi-part"
    expect(json_manifest['metadata'][0]['value'].first).to eq subject.exhibit_id.first
    expect(json_manifest['structures']).to eq nil
    expect(json_manifest['viewingDirection']).to eq nil
  end

  context "when the user doesn't have permission to a child resource" do
    subject { described_class.new(solr_doc, ability) }
    let(:ability) { Ability.new(user) }
    let(:user) { FactoryGirl.create(:user) }
    let(:scanned_resource) do
      s = FactoryGirl.build(:private_scanned_resource)
      s.member_of_collections = [collection]
      allow(s).to receive(:id).and_return("resource")
      solr.add(s.to_solr)
      s
    end
    it "doesn't show up in the collection's manifests" do
      manifest = nil
      expect { manifest = ManifestBuilder.new(subject).to_json }.not_to raise_error
      json_manifest = JSON.parse(manifest)

      expect(json_manifest["manifests"]).to be_nil
    end
  end

  describe "#label" do
    it "is an empty array" do
      expect(subject.label).to eq []
    end
  end
end
