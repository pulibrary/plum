require 'rails_helper'

RSpec.describe CollectionShowPresenter do
  subject { described_class.new(solr_doc, nil) }
  let(:solr_doc) { SolrDocument.new(doc) }
  let(:doc) do
    c = FactoryGirl.build(:collection, id: "collection")
    c.members << scanned_resource
    allow(c).to receive(:new_record?).and_return(false)
    c.to_solr
  end
  let(:scanned_resource) do
    s = FactoryGirl.build(:scanned_resource)
    allow(s).to receive(:id).and_return("resource")
    solr.add(s.to_solr)
    solr.commit
    s
  end
  let(:solr) { ActiveFedora.solr.conn }

  describe "#file_presenters" do
    it "returns presenters for each Scanned Resource" do
      expect(subject.file_presenters.map(&:id)).to eq [scanned_resource.id]
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

  describe "#label" do
    it "is an empty array" do
      expect(subject.label).to eq []
    end
  end
end
