require 'rails_helper'

RSpec.describe ScannedResourcePDF, vcr: { cassette_name: "iiif_manifest" } do
  subject { described_class.new(presenter) }
  let(:resource) do
    r = FactoryGirl.build(:scanned_resource, id: "test")
    r.ordered_members << file_set
    r.ordered_members << file_set2
    solr.add r.to_solr
    solr.add r.list_source.to_solr
    solr.commit
    r
  end
  let(:solr) { ActiveFedora.solr.conn }
  let(:file_set) do
    build_file_set(id: "x633f104n", content: file)
  end
  let(:file_set2) do
    build_file_set(id: "x633f104m", content: file2)
  end
  let(:presenter) do
    ScannedResourceShowPresenter.new(SolrDocument.new(resource.to_solr), nil)
  end

  def build_file_set(id:, content:)
    f = FactoryGirl.build(:file_set, content: content, id: id)
    solr.add f.to_solr
    solr.commit
    f
  end
  let(:file) { fixture("files/color.tif") }
  let(:file2) { fixture("files/color-landscape.tif") }

  describe "#pages" do
    it "returns the number of pages in the PDF representation" do
      expect(subject.pages).to eq 2
    end
  end

  describe "#render" do
    let(:path) { Rails.root.join("tmp", "fixture_pdf.pdf") }
    after do
      FileUtils.rm_f(path) if File.exist?(path)
    end
    it "renders a PDF to a path" do
      file = subject.render(path)
      expect(file).not_to eq false
      expect(file).to be_kind_of File
      pdf_reader = PDF::Reader.new(file.path)
      expect(pdf_reader.page_count).to eq 2
      expect(pdf_reader.pages.first.orientation).to eq "portrait"
      expect(pdf_reader.pages.last.orientation).to eq "landscape"
    end
    describe "#canvas_images" do
      let(:renderer) { ScannedResourcePDF::Renderer.new(subject, path) }
      it "returns all the IIIF ids of canvas images" do
        expect(renderer.canvas_images.map(&:url)).to eq [
          "http://192.168.99.100:5004/x6%2F33%2Ff1%2F04%2Fn-intermediate_file.jp2",
          "http://192.168.99.100:5004/x6%2F33%2Ff1%2F04%2Fm-intermediate_file.jp2"
        ]
      end
      it "has width and height" do
        expect(renderer.canvas_images.first.height).to eq 287
        expect(renderer.canvas_images.first.width).to eq 200
      end
    end
  end
end
