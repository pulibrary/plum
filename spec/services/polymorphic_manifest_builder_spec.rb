# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PolymorphicManifestBuilder, vcr: { cassette_name: "iiif_manifest" } do
  subject { described_class.new(solr_document) }

  let(:solr_document) { ScannedResourceShowPresenter.new(SolrDocument.new(record.to_solr), nil) }
  let(:record) { FactoryGirl.build(:scanned_resource, title: ["Test", "Test2"]) }
  before do
    allow(record).to receive(:persisted?).and_return(true)
    allow(record).to receive(:id).and_return("1")
    allow(record.list_source).to receive(:id).and_return("1/list_source")
    allow(record.list_source).to receive(:persisted?).and_return(true)
  end

  context "when given a MVW with Children" do
    subject { described_class.new(mvw_document) }
    let(:mvw_document) { ::DynamicShowPresenter.new.new(SolrDocument.new(mvw_record.to_solr), nil) }
    let(:mvw_record) { FactoryGirl.build(:multi_volume_work, viewing_hint: [viewing_hint]) }
    let(:manifest) { JSON.parse(subject.manifest.to_json) }
    let(:viewing_hint) { "individuals" }
    before do
      allow(mvw_record).to receive(:persisted?).and_return(true)
      allow(mvw_record).to receive(:id).and_return("2")
      allow(mvw_document).to receive(:member_presenters).and_return([solr_document])
    end
    context "when there's a mvw child" do
      before do
        allow(mvw_document).to receive(:member_presenters).and_return([mvw_document])
      end
      it "renders them" do
        expect(subject.manifests.length).to eq 1
        expect(manifest['manifests'].length).to eq 1
        expect(manifest['manifests'].first['@type']).to eq "sc:Collection"
      end
    end
    it "renders as a collection" do
      expect(manifest['@type']).to eq "sc:Collection"
      expect(manifest['@id']).to eq "http://plum.com/concern/multi_volume_works/2/manifest"
      expect(manifest['viewingHint']).to eq "multi-part"
      expect(manifest['viewingDirection']).to be_nil
    end
    it "renders a manifest for every child scanned resource" do
      expect(subject.manifests.length).to eq 1
      expect(manifest['manifests'].length).to eq 1
      expect(manifest['manifests'].first['label']).to eq solr_document.title
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
      expect(manifest['rendering']).to be nil
    end
    context "with SSL on" do
      subject { described_class.new(mvw_document, ssl: true) }
      it "renders collections with HTTPS urls" do
        expect(manifest['manifests'].first['@id']).to eq "https://plum.com/concern/scanned_resources/1/manifest"
      end
    end
    context "and some are canvases" do
      let(:file_set) do
        build_file_set("x633f104m")
      end
      let(:file_set2) do
        build_file_set("x633f104n")
      end
      let(:file_set3) do
        build_file_set("x633f104o")
      end
      let(:file_set_presenter) { FileSetPresenter.new(SolrDocument.new(file_set.to_solr), nil) }
      let(:file_set2_presenter) { FileSetPresenter.new(SolrDocument.new(file_set2.to_solr), nil) }
      let(:file_set3_presenter) { FileSetPresenter.new(SolrDocument.new(file_set3.to_solr), nil) }
      let(:sr_2) { ScannedResourceShowPresenter.new(SolrDocument.new(sr_2_resource.to_solr), nil) }
      let(:sr_2_resource) { FactoryGirl.build(:scanned_resource, id: "2") }
      let(:solr) { ActiveFedora.solr.conn }
      before do
        record.ordered_members << file_set2
        record.logical_order.order = {
          "nodes": [
            {
              "label": "Chapter 1",
              "nodes": [
                {
                  "label": file_set2.rdf_label.first,
                  "proxy": file_set2.id
                }
              ]
            }
          ]
        }
        allow(mvw_document).to receive(:member_presenters).and_return([solr_document, file_set_presenter, sr_2])
        allow(solr_document).to receive(:member_presenters).and_return([file_set2_presenter])
        allow(solr_document).to receive(:logical_order).and_return(record.logical_order.order)
        allow(sr_2).to receive(:member_presenters).and_return([file_set3_presenter])
      end
      it "renders them all as canvases" do
        expect(manifest['manifests']).to eq nil
        expect(manifest['sequences'].first['canvases'].length).to eq 3
      end
      context "and there's a viewing hint" do
        let(:viewing_hint) { "paged" }
        it "can render it" do
          expect(manifest['viewingHint']).to eq "paged"
        end
      end
      it "renders ranges" do
        expect(manifest["structures"].length).to eq 1
        first_structure = manifest["structures"].first
        expect(first_structure["viewingHint"]).to eq "top"
        expect(first_structure["ranges"].length).to eq 2
        expect(first_structure["ranges"].first["label"]).to eq record.title.join(", ")
        expect(first_structure["ranges"].first["ranges"].length).to eq 1
        expect(first_structure["ranges"].first["ranges"].first["canvases"].first).to eq manifest["sequences"].first["canvases"].first['@id']
      end
    end
  end

  def build_file_set(id, geo_mime_type = nil)
    FileSet.new.tap do |g|
      allow(g).to receive(:persisted?).and_return(true)
      allow(g).to receive(:id).and_return(id)
      original_file = Hydra::PCDM::File.new
      allow(g).to receive(:original_file).and_return(original_file)
      g.title = ["Test"]
      original_file.width = [487]
      original_file.height = [400]
      g.geo_mime_type = geo_mime_type if geo_mime_type
    end
  end

  describe "#canvases" do
    context "when there are two file sets" do
      let(:type) { ::RDF::URI('http://pcdm.org/use#ExtractedText') }
      let(:file_set) do
        build_file_set("x633f104m")
      end
      let(:file_set2) do
        build_file_set("x633f104n")
      end
      let(:solr) { ActiveFedora.solr.conn }
      before do
        allow(file_set).to receive(:ocr_text).and_return(['foo'])
        record.ordered_members << file_set2
        record.ordered_member_proxies.insert_target_at(0, file_set)
        record.thumbnail = file_set2
        record.start_canvas = [file_set2.id]
        record.logical_order.order = {
          "label": "TOP!",
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
        expect(manifest_json["sequences"].first["canvases"].first["width"]).to eq 487
        expect(manifest_json["sequences"].first["canvases"].first["height"]).to eq 400
      end
      it "has a label" do
        expect(first_canvas.label).to eq file_set.to_s
      end
      it "uses the selected fileset as a thumbnail" do
        expect(manifest_json["thumbnail"]).to eq(
          "@id" => "http://192.168.99.100:5004/x6%2F33%2Ff1%2F04%2Fn-intermediate_file.jp2/full/!200,150/0/default.jpg",
          "service" => {
            "@context" => "http://iiif.io/api/image/2/context.json",
            "@id" => "http://192.168.99.100:5004/x6%2F33%2Ff1%2F04%2Fn-intermediate_file.jp2",
            "profile" => "http://iiif.io/api/image/2/level2.json"
          }
        )
      end
      it "applies the startCanvas option for the start_canvas" do
        expect(manifest_json["sequences"].first["startCanvas"]).to eq manifest_json["sequences"].first["canvases"].last["@id"]
      end
      it "has a viewing hint on the sequence" do
        expect(manifest_json["sequences"].first["viewingHint"]).to eq "individuals"
      end
      it "has a viewing hint" do
        file_set.viewing_hint = ["non-paged"]
        solr.add file_set.to_solr
        solr.commit

        expect(first_canvas.viewing_hint).to eq "non-paged"
        expect { subject.manifest.to_json }.not_to raise_error
      end
      it "handles facing-pages" do
        file_set.viewing_hint = ["facing-pages"]
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
        expect(first_structure["label"]).to eq "TOP!"
        expect(first_structure["ranges"].length).to eq 1
        expect(first_structure["ranges"].first["canvases"].length).to eq 2
        expect(first_structure["ranges"].first["canvases"].first).to eq manifest_json["sequences"].first["canvases"].first['@id']
      end
      it "has a pdf link" do
        expect(manifest_json['sequences'][0]["rendering"]["@id"]).to eql "http://plum.com/concern/scanned_resources/1/pdf/gray"
      end
      context "when given a color PDF enabled resource" do
        let(:record) { FactoryGirl.build(:scanned_resource, pdf_type: ['color']) }
        it "has a color PDF link" do
          expect(manifest_json['sequences'][0]["rendering"]["@id"]).to eql "http://plum.com/concern/scanned_resources/1/pdf/color"
        end
      end
      context "when given a bitonal PDF enabled resource" do
        let(:record) { FactoryGirl.build(:scanned_resource, pdf_type: ['bitonal']) }
        it "has a color PDF link" do
          expect(manifest_json['sequences'][0]["rendering"]["@id"]).to eql "http://plum.com/concern/scanned_resources/1/pdf/bitonal"
        end
      end
      context "when the PDF type is not specified" do
        let(:record) { FactoryGirl.build(:scanned_resource, pdf_type: []) }
        it "has a grayscale PDF link" do
          expect(manifest_json['sequences'][0]["rendering"]["@id"]).to eql "http://plum.com/concern/scanned_resources/1/pdf/gray"
        end
      end
      context "when the PDF type is 'none'" do
        let(:record) { FactoryGirl.build(:scanned_resource, pdf_type: ['none']) }
        it "does not have a PDF link" do
          expect(manifest_json['sequences'][0]["rendering"]).to be nil
        end
      end
      context "when given SSL" do
        subject { described_class.new(solr_document, ssl: true) }
        it "generates https links appropriately for pdfs" do
          expect(manifest_json['sequences'][0]["rendering"]["@id"]).to eql "https://plum.com/concern/scanned_resources/1/pdf/gray"
        end
      end
      it "has an otherContent" do
        first_canvas = manifest_json["sequences"][0]["canvases"][0]
        expect(first_canvas["otherContent"][0]["@id"]).to eq "http://plum.com/concern/container/1/file_sets/x633f104m/text"
      end
    end

    context "when there is a geo image file set and an external metadata file set" do
      let(:record) { FactoryGirl.build(:image_work, title: ["Test"]) }
      let(:file_set) do
        build_file_set("z633f104m", "image/tiff")
      end
      let(:file_set2) do
        build_file_set("z33f104n", "application/xml; schema=fgdc")
      end
      let(:solr) { ActiveFedora.solr.conn }
      before do
        allow(file_set).to receive(:ocr_text).and_return(['foo'])
        record.ordered_members << file_set2
        record.ordered_member_proxies.insert_target_at(0, file_set)
        record.thumbnail = file_set
        solr.add file_set.to_solr
        solr.add file_set2.to_solr
        solr.add record.list_source.to_solr
        solr.commit
      end
      let(:manifest_json) { JSON.parse(subject.to_json) }

      it "only has one canvas for the image" do
        expect(manifest_json["sequences"].first["canvases"].length).to eq 1
      end
    end

    it "has none" do
      expect(subject.canvases).to eq []
    end
  end

  describe "#manifest" do
    let(:result) { subject.manifest }
    let(:json_result) { JSON.parse(result.to_json) }
    it "includes basic metadata in JSON-LD format" do
      expect(json_result["@context"]).to eq("http://iiif.io/api/presentation/2/context.json")
      expect(json_result["@id"]).to eq("http://plum.com/concern/scanned_resources/1/manifest")
      expect(json_result["@type"]).to eq("sc:Manifest")
      expect(json_result["label"]).to contain_exactly("Test", "Test2")
      expect(json_result["description"]).to eq(["900 years of time and space, and I’ve never been slapped by someone’s mother."])
      expect(json_result["viewingHint"]).to eq("individuals")
      expect(json_result["viewingDirection"]).to eq("left-to-right")
    end
    it "has a label" do
      expect(result.label).to eq ScannedResourceShowPresenter.new(SolrDocument.new(record.to_solr), nil).title
    end
    it "has an ID" do
      expect(result['@id']).to eq "http://plum.com/concern/scanned_resources/1/manifest"
    end
    it "has a description" do
      expect(result.description).to eq Array(record.description)
    end
    it "has a license" do
      expect(result.license).to eq('http://rightsstatements.org/vocab/NKC/1.0/')
    end
    it "has a logo" do
      expect(result.logo).to eq('http://plum.com/assets/pul_logo_icon.png')
    end
    context "with a Vatican/Cicognara rights statement" do
      before do
        record.rights_statement = ['http://cicognara.org/microfiche_copyright']
      end
      let(:result) { subject.manifest }
      it "uses the Vatican logo" do
        expect(result.logo).to eq('http://plum.com/assets/vatican.png')
      end
    end
    context "when it has a bibdata ID" do
      it "links to JSON-LD and bibdata" do
        expect(json_result["seeAlso"].first["@id"]).to eq "http://plum.com/concern/scanned_resources/1.jsonld"
        expect(json_result["seeAlso"].first["format"]).to eq "application/ld+json"
        expect(json_result["seeAlso"].last["@id"]).to eq "https://bibdata.princeton.edu/bibliographic/1234567"
        expect(json_result["seeAlso"].last["format"]).to eq "text/xml"
      end
    end
    context "when it has an identifier" do
      it "links to the princeton ark service" do
        record.identifier = ["ark:/88435/7w62fb79g"]
        expect(json_result["rendering"]["@id"]).to eq "http://arks.princeton.edu/ark:/88435/7w62fb79g"
        expect(json_result["rendering"]["format"]).to eq "text/html"
      end
    end
    context "when it has no bibdata id" do
      let(:record) { FactoryGirl.build(:scanned_resource, source_metadata_identifier: nil) }
      it "links to seeAlso" do
        expect(json_result["seeAlso"]["@id"]).to eq "http://plum.com/concern/scanned_resources/1.jsonld"
        expect(json_result["seeAlso"]["format"]).to eq "application/ld+json"
      end
    end
    describe "metadata" do
      it "has a creator" do
        record.creator = ["Test Author"]
        expect(result.metadata.first).to eql(
          "label" => "Creator",
          "value" => [
            "Test Author"
          ]
        )
      end
      it "can do authors" do
        record.author = ["Test Author"]
        expect(result.metadata.first).to eql(
          "label" => "Author",
          "value" => [
            "Test Author"
          ]
        )
      end
      it "converts languages" do
        record.language = ["ara"]
        expect(result.metadata.first).to eql(
          "label" => "Language",
          "value" => [
            "Arabic"
          ]
        )
      end
      it "can handle RDF literals" do
        record.creator = [::RDF::Literal.new("Test Author", language: "fr")]
        expect(result.metadata.first).to eql(
          "label" => "Creator",
          "value" => [
            {
              "@value" => "Test Author",
              "@language" => "fr"
            }
          ]
        )
      end
      it "has the right label for publisher" do
        record.publisher = ["1987"]
        expect(result.metadata.first).to eql(
          "label" => "Published/Created",
          "value" => [
            "1987"
          ]
        )
      end
      it "doesn't display sort title" do
        record.sort_title = ["Bla"]
        expect(result.metadata).to be_empty
      end
      it "doesn't display created" do
        record.created = ["Test"]
        expect(result.metadata).to be_empty
      end
      it "doesn't display date" do
        record.date = ["1917"]
        expect(result.metadata).to be_empty
      end
      it "doesn't display part of" do
        record.part_of = ["Testing"]
        expect(result.metadata).to be_empty
      end
      it "is empty with no metadata" do
        expect(result.metadata).to be_empty
      end
      it "doesn't render ocr_language" do
        record.ocr_language = ["test"]
        expect(result.metadata.first).to be_nil
      end
    end
    describe "a record in a collection" do
      let(:resource) { FactoryGirl.create(:scanned_resource_in_collection) }
      let(:solr_document) { ScannedResourceShowPresenter.new(SolrDocument.new(resource.to_solr), nil) }

      it "has collection title" do
        expect(subject.manifest.metadata.first).to eql(
          "label" => "Collection",
          "value" => [
            "Test Collection"
          ]
        )
      end
    end
    it "has a viewing hint" do
      record.viewing_hint = ["paged"]
      expect(result.viewing_hint).to eq "paged"
    end
    it "has a default viewing hint" do
      expect(result.viewing_hint).to eq "individuals"
    end
    it "has a viewing direction" do
      record.viewing_direction = ["right-to-left"]
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

  context 'with an invalid IIIF Manifest' do
    describe '.new' do
      let(:manifest_builder) { class_double(ManifestBuilder).as_stubbed_const(transfer_nested_constants: true) }
      let(:manifest) { instance_double(IIIF::Presentation::Manifest) }

      context 'with an invalid manifest' do
        before do
          allow(manifest).to receive(:to_json).and_return("{}")
          allow(manifest_builder).to receive(:new).and_return(manifest)
        end

        it 'raises an error if the manifest is blank' do
          expect { described_class.new(solr_document) }.to raise_error(ManifestBuilder::ManifestEmptyError, I18n.t('works.show.no_image'))
        end
      end

      context 'with an empty manifest' do
        before do
          allow(manifest_builder).to receive(:new).and_raise(StandardError)
        end

        it 'raises an error if the manifest is invalid' do
          expect { described_class.new(solr_document) }.to raise_error(ManifestBuilder::ManifestBuildError, I18n.t('works.show.no_image'))
        end
      end
    end
  end
end
