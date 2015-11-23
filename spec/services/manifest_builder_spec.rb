require 'rails_helper'

RSpec.describe ManifestBuilder, vcr: { cassette_name: "iiif_manifest" } do
  subject { described_class.new(solr_document) }

  let(:solr_document) { ScannedResourceShowPresenter.new(SolrDocument.new(record.to_solr), nil) }
  let(:record) { FactoryGirl.build(:scanned_resource) }
  before do
    allow(record).to receive(:persisted?).and_return(true)
    allow(record).to receive(:id).and_return("1")
    allow(record.list_source).to receive(:id).and_return("1/list_source")
    allow(record.list_source).to receive(:persisted?).and_return(true)
  end

  context "when given a MVW with Children" do
    subject { described_class.new(mvw_document) }
    let(:mvw_document) { MultiVolumeWorkShowPresenter.new(SolrDocument.new(mvw_record.to_solr), nil) }
    let(:mvw_record) { FactoryGirl.build(:multi_volume_work) }
    let(:manifest) { JSON.parse(subject.manifest.to_json) }
    before do
      allow(mvw_record).to receive(:persisted?).and_return(true)
      allow(mvw_record).to receive(:id).and_return("2")
      allow(mvw_document).to receive(:file_presenters).and_return([solr_document])
    end
    it "renders as a collection" do
      expect(manifest['@type']).to eq "sc:Collection"
      expect(manifest['@id']).to eq "http://plum.com/concern/multi_volume_works/2/manifest"
    end
    it "renders a manifest for every child scanned resource" do
      expect(manifest['manifests'].length).to eq 1
      expect(manifest['manifests'].first['label']).to eq solr_document.to_s
      expect(manifest['manifests'].first['@type']).to eq "sc:Manifest"
    end
    context "with SSL on" do
      subject { described_class.new(mvw_document, ssl: true) }
      it "renders collections with HTTPS urls" do
        expect(manifest['manifests'].first['@id']).to eq "https://plum.com/concern/scanned_resources/1/manifest"
      end
    end
  end

  describe "#canvases" do
    context "when there is two file sets" do
      let(:type) { ::RDF::URI('http://pcdm.org/use#ExtractedText') }
      let(:file_set) do
        build_file_set("x633f104m")
      end
      let(:file_set2) do
        build_file_set("x633f104n")
      end
      let(:solr) { ActiveFedora.solr.conn }
      def build_file_set(id)
        FileSet.new.tap do |g|
          allow(g).to receive(:persisted?).and_return(true)
          allow(g).to receive(:id).and_return(id)
        end
      end
      before do
        record.ordered_members << file_set2
        record.ordered_member_proxies.insert_target_at(0, file_set)
        solr.add file_set.to_solr
        solr.add file_set2.to_solr
        solr.add record.list_source.to_solr
        solr.commit
      end
      let(:first_canvas) { subject.canvases.first }
      let(:manifest_json) { JSON.parse(subject.to_json) }
      it "has two" do
        expect(subject.canvases.length).to eq 2
        expect(manifest_json["sequences"].first["canvases"].length).to eq 2
      end
      it "has a label" do
        expect(first_canvas.label).to eq file_set.to_s
      end
      it "has a viewing hint" do
        file_set.viewing_hint = "non-paged"
        solr.add file_set.to_solr
        solr.commit

        expect(first_canvas.viewing_hint).to eq "non-paged"
        expect { subject.manifest.to_json }.not_to raise_error
      end
      it "handles facing-pages" do
        file_set.viewing_hint = "facing-pages"
        solr.add file_set.to_solr
        solr.commit

        expect(first_canvas.viewing_hint).to eq "facing-pages"
        expect { subject.manifest.to_json }.not_to raise_error
      end
      it "is a valid manifest" do
        expect { subject.manifest.to_json }.not_to raise_error
      end
      it "has an ordered image" do
        first_image = first_canvas.images.first
        expect(first_canvas.images.length).to eq 1
        expect(first_image.resource.format).to eq "image/jpeg"
        expect(first_image.resource.service['@id']).to eq "http://192.168.99.100:5004/x6%2F33%2Ff1%2F04%2Fm-intermediate_file.jp2"
        expect(first_image["on"]).to eq first_canvas['@id']
      end
    end
    it "has none" do
      expect(subject.canvases).to eq []
    end
  end

  describe "#manifest" do
    let(:result) { subject.manifest }
    xit "should have a good JSON-LD result" do
    end
    it "has a label" do
      expect(result.label).to eq record.to_s
    end
    it "has an ID" do
      expect(result['@id']).to eq "http://plum.com/concern/scanned_resources/1/manifest"
    end
    it "has a description" do
      expect(result.description).to eq record.description
    end
    it "has a viewing hint" do
      record.viewing_hint = "paged"
      expect(result.viewing_hint).to eq "paged"
    end
    it "has a default viewing hint" do
      expect(result.viewing_hint).to eq "individuals"
    end
    it "has a viewing direction" do
      record.viewing_direction = "right-to-left"
      expect(result.viewing_direction).to eq "right-to-left"
    end
    it "has a default viewing direction" do
      expect(result.viewing_direction).to eq "left-to-right"
    end
    it "is valid" do
      expect { subject.manifest.to_json }.not_to raise_error
    end
    context "with SSL on" do
      subject { described_class.new(solr_document, ssl: true) }
      it "has an SSL ID" do
        expect(result['@id']).to eq "https://plum.com/concern/scanned_resources/1/manifest"
      end
    end
  end
end
