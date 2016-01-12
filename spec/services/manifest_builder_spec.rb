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
      expect(manifest['viewingHint']).to eq "multi-part"
    end
    it "renders a manifest for every child scanned resource" do
      expect(subject.manifests.length).to eq 1
      expect(manifest['manifests'].length).to eq 1
      expect(manifest['manifests'].first['label']).to eq solr_document.to_s
      expect(manifest['manifests'].first['@type']).to eq "sc:Manifest"
    end
    it "doesn't render structures for child manifests" do
      expect(manifest['manifests'].first['structures']).to eq nil
    end
    it "doesn't render canvases for child manifests" do
      allow(ManifestBuilder::SequenceBuilder).to receive(:new).and_call_original

      expect(manifest['manifests'].first['sequences']).to eq nil
      expect(ManifestBuilder::SequenceBuilder).to have_received(:new).exactly(1).times
    end
    it "doesn't generate a PDF link" do
      expect(manifest['rendering']).to eql nil
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
          g.title = ["Test"]
        end
      end
      before do
        record.ordered_members << file_set2
        record.ordered_member_proxies.insert_target_at(0, file_set)
        record.logical_order.order = {
          "nodes": [
            {
              "label": "Chapter 1",
              "nodes": [
                {
                  "label": file_set.rdf_label.first,
                  "proxy": file_set.id
                },
                {
                  "label": file_set2.rdf_label.first,
                  "proxy": file_set2.id
                }
              ]
            },
            {
              "label": "Bla"
            }
          ]
        }
        solr.add file_set.to_solr
        solr.add file_set2.to_solr
        solr.add record.list_source.to_solr
        solr.commit
      end
      let(:first_canvas) { subject.canvases.first }
      let(:manifest_json) { JSON.parse(subject.to_json) }
      it "has two" do
        expect(manifest_json["sequences"].first["canvases"].length).to eq 2
      end
      it "has a label" do
        expect(first_canvas.label).to eq file_set.to_s
      end
      it "uses the first one as a thumbnail" do
        expect(manifest_json["thumbnail"]).to eq(
          "@id" => "http://192.168.99.100:5004/x6%2F33%2Ff1%2F04%2Fm-intermediate_file.jp2/full/100,/0/default.jpg",
          "service" => {
            "@context" => "http://iiif.io/api/image/2/context.json",
            "@id" => "http://192.168.99.100:5004/x6%2F33%2Ff1%2F04%2Fm-intermediate_file.jp2",
            "profile" => "http://iiif.io/api/image/2/level2.json"
          }
        )
      end
      it "has a viewing hint on the sequence" do
        expect(manifest_json["sequences"].first["viewingHint"]).to eq "individuals"
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
      it "builds ranges" do
        expect(manifest_json["structures"].length).to eq 1
        first_structure = manifest_json["structures"].first
        expect(first_structure["viewingHint"]).to eq "top"
        expect(first_structure["ranges"].length).to eq 1
        expect(first_structure["ranges"].first["canvases"].length).to eq 2
        expect(first_structure["ranges"].first["canvases"].first).to eq manifest_json["sequences"].first["canvases"].first['@id']
      end
      it "has a pdf link" do
        expect(manifest_json['sequences'][0]["rendering"]["@id"]).to eql "http://plum.com/concern/scanned_resources/1/pdf"
      end
      context "when given SSL" do
        subject { described_class.new(solr_document, ssl: true) }
        it "generates https links appropriately for pdfs" do
          expect(manifest_json['sequences'][0]["rendering"]["@id"]).to eql "https://plum.com/concern/scanned_resources/1/pdf"
        end
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
    describe "metadata" do
      it "has a creator" do
        record.creator = ["Test Author"]
        expect(result.metadata.first).to eql(
          "label" => "Creator",
          "value" => [
            {
              "@value" => "Test Author"
            }
          ]
        )
      end
      it "is empty with no metadata" do
        expect(result.metadata).to be_empty
      end
      it "has a date created" do
        record.date_created = ["1981"]
        expect(result.metadata).not_to be_empty
      end
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
