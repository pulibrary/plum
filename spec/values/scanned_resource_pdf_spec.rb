require 'rails_helper'

RSpec.describe ScannedResourcePDF, vcr: { cassette_name: "iiif_manifest" } do
  subject { described_class.new(presenter) }
  let(:resource) do
    r = FactoryGirl.build(:scanned_resource, id: "test", holding_location: "https://bibdata.princeton.edu/locations/delivery_locations/3")
    r.ordered_members << file_set
    r.ordered_members << file_set2
    r.logical_order.order = order
    r.title = ["Leonardo's Book é 祝 ي"]
    r.description = "All about Leonardo."
    r.author = ["Leonardo"]
    solr.add r.to_solr
    solr.add r.list_source.to_solr
    solr.commit
    r
  end
  let(:order) { {} }
  let(:solr) { ActiveFedora.solr.conn }
  let(:file_set) do
    build_file_set(id: "x633f104n", content: file, title: "Page 1")
  end
  let(:file_set2) do
    build_file_set(id: "x633f104m", content: file2, title: "Page 2")
  end
  let(:presenter) do
    ScannedResourceShowPresenter.new(SolrDocument.new(resource.to_solr), nil)
  end

  def build_file_set(id:, content:, title: nil)
    f = FactoryGirl.build(:file_set, content: content, id: id, title: Array.wrap(title))
    solr.add f.to_solr
    solr.commit
    f
  end
  let(:file) { fixture("files/color.tif") }
  let(:file2) { fixture("files/color-landscape.tif") }

  describe "#pages" do
    it "returns the number of pages in the PDF representation" do
      expect(subject.pages).to eq 3 # Num. of canvases + cover page
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
      expect(pdf_reader.page_count).to eq 3 # Including cover page
      expect(pdf_reader.pages.first.orientation).to eq "portrait"
      expect(pdf_reader.pages.last.orientation).to eq "landscape"
      expect(pdf_reader.info[:Author]).to eq "Leonardo"
      expect(pdf_reader.info[:Title]).to eq "Leonardo's Book é 祝 ي"
      expect(pdf_reader.info[:Description]).to eq "All about Leonardo."
    end
    it "doesn't re-render if it exists already" do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(path).and_return(true)
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(path).and_return("test")
      allow(ScannedResourcePDF::Renderer).to receive(:new).and_call_original
      file = subject.render(path)
      expect(file).to eq "test"
      expect(ScannedResourcePDF::Renderer).not_to have_received(:new)
    end
    context "when there's an order" do
      let(:order) do
        {
          "nodes": [
            {
              "label": "Chapter 1",
              "nodes":
              [
                {
                  "label": "Chapter 1a",
                  "nodes": [
                    {
                      "proxy": file_set.id
                    }
                  ]
                },
                {
                  "label": "Chapter 1b",
                  "nodes": [
                  ]
                }
              ]
            },
            {
              "proxy": file_set2.id
            }
          ]
        }
      end
      it "builds up an outline" do
        renderer = ScannedResourcePDF::Renderer.new(subject, path)
        renderer.render
        @pdf = renderer.send(:prawn_document)
        render_and_find_objects
        # First element is Chapter 1
        expect(referenced_object(@outline_root[:First])).to eql @section_1
        # Last element is Page 2
        expect(referenced_object(@outline_root[:Last])).to eql @page_2
        # First element of Chapter 1 is Chapter 1a
        expect(referenced_object(@section_1[:First])).to eql @section_1a
        # Last element of Chapter 1 is Chapter 1b
        expect(referenced_object(@section_1[:Last])).to eql @section_1b
        # First element of Chapter 1a is Page 1
        expect(referenced_object(@section_1a[:First])).to eql @page_1
      end
      def render_and_find_objects
        output = StringIO.new(@pdf.render, 'r+')
        @hash = PDF::Reader::ObjectHash.new(output)
        @outline_root = @hash.values.find { |obj| obj.is_a?(Hash) && obj[:Type] == :Outlines }
        @pages = @hash.values.find { |obj| obj.is_a?(Hash) && obj[:Type] == :Pages }[:Kids]
        @section_1 = find_by_title('Chapter 1')
        @page_1 = find_by_title('Page 1')
        @section_1a = find_by_title('Chapter 1a')
        @section_1b = find_by_title('Chapter 1b')
        @page_2 = find_by_title('Page 2')
      end

      # Outline titles are stored as UTF-16. This method accepts a UTF-8 outline title
      # and returns the PDF Object that contains an outline with that name
      def find_by_title(title)
        @hash.values.find {|obj|
          next unless obj.is_a?(Hash) && obj[:Title]
          title_codepoints = obj[:Title].unpack("n*")
          title_codepoints.shift
          utf8_title = title_codepoints.pack("U*")
          utf8_title == title ? obj : nil
        }
      end

      def referenced_object(reference)
        @hash[reference]
      end
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
