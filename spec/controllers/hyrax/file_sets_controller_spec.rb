require 'rails_helper'

RSpec.describe Hyrax::FileSetsController do
  let(:file_set) { FactoryGirl.build(:file_set) }
  let(:parent) { FactoryGirl.create(:scanned_resource) }
  let(:user) { FactoryGirl.create(:admin) }
  let(:file) { fixture_file_upload("files/color.tif", "image/tiff") }
  let(:generator) { instance_double(GeoWorks::EventsGenerator) }

  before do
    allow_any_instance_of(described_class).to receive(:curation_concern).and_return(file_set)
    allow(file_set).to receive(:parent).and_return(parent)
    allow(GeoWorks::EventsGenerator).to receive(:new).and_return(generator)
  end

  describe "#update" do
    before do
      sign_in user
      file_set.save
    end
    it "can update viewing_hint" do
      allow_any_instance_of(described_class).to receive(:parent_id).and_return(nil)
      patch :update, params: { id: file_set.id, file_set: { viewing_hint: 'non-paged' } }
      expect(file_set.reload.viewing_hint).to eq 'non-paged'
    end
    context "when updating via json" do
      render_views
      it "can update title" do
        allow_any_instance_of(described_class).to receive(:parent_id).and_return(nil)
        patch :update, params: { id: file_set.id, file_set: { viewing_hint: '', title: ["test"] }, format: :json }
        expect(response).to be_success
        file_set.reload
        expect(file_set.viewing_hint).to eq ""
        expect(file_set.title).to eq ["test"]
      end
    end
    it "redirects to the containing scanned resource after editing" do
      allow_any_instance_of(described_class).to receive(:parent).and_return(parent)
      allow_any_instance_of(described_class).to receive(:geo?).and_return(false)
      patch :update, params: { id: file_set.id, file_set: { viewing_hint: 'non-paged' } }
      expect(response).to redirect_to(Rails.application.class.routes.url_helpers.file_manager_hyrax_scanned_resource_path(parent.id, locale: 'en'))
    end

    context "with a geo work" do
      let(:parent) { FactoryGirl.create(:vector_work) }

      before do
        allow(parent).to receive(:workflow_state).and_return('complete')
      end
      it "sends an update message for the parent and redirects to file_set page" do
        expect(generator).to receive(:record_updated)
        patch :update, params: { id: file_set.id, file_set: { title: ["test"] } }
        expect(response).to redirect_to(Rails.application.class.routes.url_helpers.hyrax_file_set_path(file_set.id, locale: 'en'))
      end
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
      post :create, params: { parent_id: parent, file_set: { files: [file], title: ['test title'], visibility: 'restricted' } }, xhr: true
      expect(FileSet.all.length).to eq 1
      expect(manifest_generator).to have_received(:record_updated).with(parent)
    end

    context "with a geo work" do
      let(:parent) { FactoryGirl.create(:vector_work) }

      before do
        allow(parent).to receive(:workflow_state).and_return('complete')
      end
      it "sends an update message for the parent" do
        expect(generator).to receive(:record_updated)
        post :create, params: { parent_id: parent, file_set: { files: [file], title: ['test title'], visibility: 'restricted' } }, xhr: true
      end
    end
  end

  describe "#destroy" do
    before do
      sign_in user
    end
    context "with a geo work" do
      let(:parent) { FactoryGirl.create(:vector_work) }
      let(:actor) { double }
      before do
        file_set.save
        allow(parent).to receive(:workflow_state).and_return('complete')
      end
      it "sends an update message for the parent" do
        expect(generator).to receive(:record_updated)
        delete :destroy, params: { id: file_set }
      end
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
    let(:parent_path) { "http://plum.com/concern/container/#{parent.id}/file_sets/#{file_set.id}/text" }
    let(:canvas_id) { "http://plum.com/concern/scanned_resources/#{parent.id}/manifest/canvas/#{file_set.id}" }
    let(:bounding_box) do
      b = ocr_document.lines.first.bounding_box
      "#{b.top_left.x},#{b.top_left.y},#{b.width},#{b.height}"
    end
    it "returns a manifest for the file set" do
      get :text, params: { parent_id: parent.id, id: file_set.id, format: :json }

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

  describe "#derivatives" do
    before do
      sign_in user
      FileSetActor.new(file_set, user).attach_content(file)
      allow(CreateDerivativesJob).to receive(:perform_later)
      allow_any_instance_of(described_class).to receive(:parent_id).and_return(nil)
    end
    it "triggers regenerating derivatives" do
      post :derivatives, params: { id: file_set.id }
      expect(CreateDerivativesJob).to have_received(:perform_later)
    end
  end
end
