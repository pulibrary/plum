require 'rails_helper'

RSpec.describe AnnotationListBuilder do
  subject { described_class.new(file_set, parent_path, canvas_id) }
  let(:file_set) do
    instance_double(FileSet, ocr_document: hocr)
  end
  let(:parent_path) do
    "http://test.com/file_sets/1/text"
  end
  let(:canvas_id) do
    "http://test.com/canvas/1"
  end
  let(:hocr) { nil }

  describe "#as_json" do
    context "when there's no HOCR attached" do
      it "is empty" do
        expect(subject.as_json).to eq(
          "@context" => "http://iiif.io/api/presentation/2/context.json",
          "@id" => "#{parent_path}",
          "@type" => "sc:AnnotationList"
        )
      end
    end
    context "when there's HOCR attached" do
      let(:hocr) do
        HOCRDocument.new(File.open(document))
      end
      let(:document) { File.open(Rails.root.join("spec", "fixtures", "files", "test.hocr")) }
      let(:bounding_box) do
        b = hocr.lines.first.bounding_box
        "#{b.top_left.x},#{b.top_left.y},#{b.width},#{b.height}"
      end

      it "builds a resource for every line" do
        expect(subject.as_json).to eq(
          "@context" => "http://iiif.io/api/presentation/2/context.json",
          "@id" => "#{parent_path}",
          "@type" => "sc:AnnotationList",
          "resources" => [
            {
              "@id" => "#{parent_path}/line_1_3",
              "@type" => "oa:Annotation",
              "motivation" => "sc:painting",
              "resource" => {
                "@id" => "#{parent_path}/line_1_3/1",
                "@type" => "cnt:ContentAsText",
                "format" => "text/plain",
                "chars" => hocr.lines.first.text
              },
              "on" => "#{canvas_id}#xywh=#{bounding_box}"
            }
          ]
        )
      end
    end
  end
end
