require 'rails_helper'

RSpec.describe CurationConcerns::FileSetsController do
  let(:file_set) { FactoryGirl.build(:file_set) }
  let(:parent) { FactoryGirl.create(:scanned_resource) }
  let(:user) { FactoryGirl.create(:admin) }
  let(:file) { fixture_file_upload("files/color.tif", "image/tiff") }
  describe "#update" do
    before do
      sign_in user
      file_set.save
    end
    it "can update viewing_hint" do
      allow_any_instance_of(described_class).to receive(:parent_id).and_return(nil)
      patch :update, id: file_set.id, file_set: { viewing_hint: 'non-paged' }
      expect(file_set.reload.viewing_hint).to eq 'non-paged'
    end
    it "redirects to the containing scanned resource after editing" do
      allow_any_instance_of(described_class).to receive(:parent).and_return(parent)
      patch :update, id: file_set.id, file_set: { viewing_hint: 'non-paged' }
      expect(response).to redirect_to(Rails.application.class.routes.url_helpers.file_manager_curation_concerns_scanned_resource_path(parent.id))
    end
  end

  describe "#create" do
    before do
      sign_in user
    end
    it "sends an update message for the parent" do
      manifest_generator = instance_double(ManifestEventGenerator, record_updated: true)
      allow(ManifestEventGenerator).to receive(:new).and_return(manifest_generator)
      allow(IngestFileJob).to receive(:perform_later).and_return(true)
      allow(CharacterizeJob).to receive(:perform_later).and_return(true)
      xhr :post, :create, parent_id: parent,
                          file_set: { files: [file],
                                      title: ['test title'],
                                      visibility: 'restricted' }

      expect(FileSet.all.length).to eq 1
      expect(manifest_generator).to have_received(:record_updated).with(parent)
    end
  end

  describe "#text" do
    before do
      sign_in user
      file_set.save
      parent.ordered_members << file_set
      parent.save
      allow_any_instance_of(FileSet).to receive(:ocr_document).and_return(ocr_document)
    end
    let(:document) { File.open(Rails.root.join("spec", "fixtures", "files", "test.hocr")) }
    let(:ocr_document) { HOCRDocument.new(document) }
    let(:parent_path) { "http://test.host/concern/container/#{parent.id}/file_sets/#{file_set.id}/text" }
    let(:canvas_id) { "http://test.host/concern/scanned_resources/#{parent.id}/manifest/canvas/#{file_set.id}" }
    let(:bounding_box) do
      b = ocr_document.lines.first.bounding_box
      "#{b.top_left.x},#{b.top_left.y},#{b.width},#{b.height}"
    end
    it "returns a manifest for the file set" do
      get :text, parent_id: parent.id, id: file_set.id, format: :json

      expect(JSON.parse(response.body)).to eq(
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
              "chars" => ocr_document.lines.first.text
            },
            "on" => "#{canvas_id}#xywh=#{bounding_box}"
          }
        ]
      )
    end
  end
end
