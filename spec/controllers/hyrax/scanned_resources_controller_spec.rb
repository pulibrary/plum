require 'rails_helper'

describe Hyrax::ScannedResourcesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:scanned_resource) { FactoryGirl.create(:complete_scanned_resource, user: user, title: ['Dummy Title'], identifier: 'ark:/99999/fk4445wg45') }
  let(:reloaded) { scanned_resource.reload }

  describe "delete" do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
    end

    it "deletes a record" do
      s = FactoryGirl.create(:scanned_resource)

      delete :destroy, params: { id: s.id }

      expect(ScannedResource.all.length).to eq 0
    end

    it "fires a delete event" do
      s = FactoryGirl.create(:scanned_resource)
      manifest_generator = instance_double(ManifestEventGenerator, record_deleted: true)
      allow(ManifestEventGenerator).to receive(:new).and_return(manifest_generator)

      delete :destroy, params: { id: s.id }

      expect(manifest_generator).to have_received(:record_deleted)
    end
  end
  describe "create" do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
    end
    context "when given a bib id", vcr: { cassette_name: 'bibdata', record: :new_episodes } do
      let(:scanned_resource_attributes) do
        FactoryGirl.attributes_for(:scanned_resource).merge(
          source_metadata_identifier: "2028405"
        )
      end
      it "updates the metadata" do
        post :create, params: { scanned_resource: scanned_resource_attributes }
        s = ScannedResource.last
        expect(s.title.first.to_s).to eq 'The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.'
      end
      it "posts a creation event to the queue" do
        manifest_generator = instance_double(ManifestEventGenerator, record_created: true, record_updated: true)
        allow(ManifestEventGenerator).to receive(:new).and_return(manifest_generator)

        post :create, params: { scanned_resource: scanned_resource_attributes }

        expect(manifest_generator).to have_received(:record_created).with(ScannedResource.last)
      end
    end
    context "when given a non-existent bib id", vcr: { cassette_name: 'bibdata_not_found', allow_playback_repeats: true } do
      let(:scanned_resource_attributes) do
        FactoryGirl.attributes_for(:scanned_resource).merge(
          source_metadata_identifier: "0000000"
        )
      end
      it "receives an error" do
        expect do
          post :create, params: { scanned_resource: scanned_resource_attributes }
        end.not_to change { ScannedResource.count }
        expect(response.status).to be 422
      end
      it "doesn't post a creation event" do
        manifest_generator = instance_double(ManifestEventGenerator, record_created: true)
        allow(ManifestEventGenerator).to receive(:new).and_return(manifest_generator)

        post :create, params: { scanned_resource: scanned_resource_attributes }

        expect(manifest_generator).not_to have_received(:record_created)
      end
    end
    context "when selecting a collection" do
      let(:collection) { FactoryGirl.create(:collection, user: user) }
      let(:scanned_resource_attributes) do
        FactoryGirl.attributes_for(:scanned_resource).except(:source_metadata_identifier).merge(
          member_of_collection_ids: [collection.id]
        )
      end
      it "successfully add the resource to the collection" do
        post :create, params: { scanned_resource: scanned_resource_attributes }
        s = ScannedResource.last
        expect(s.member_of_collections).to eq [collection]
      end
      it "posts the collection slugs to the event endpoint" do
        messaging_client = instance_double(MessagingClient, publish: true)
        manifest_generator = ManifestEventGenerator.new(messaging_client)
        allow(ManifestEventGenerator).to receive(:new).and_return(manifest_generator)

        post :create, params: { scanned_resource: scanned_resource_attributes }

        s = ScannedResource.last

        expect(messaging_client).to have_received(:publish).with(
          {
            "id" => s.id,
            "event" => "CREATED",
            "manifest_url" => "http://plum.com/concern/scanned_resources/#{s.id}/manifest",
            "collection_slugs" => s.member_of_collections.map(&:exhibit_id)
          }.to_json
        )
      end
    end
  end

  describe "#manifest" do
    let(:solr) { ActiveFedora.solr.conn }
    let(:user) { FactoryGirl.create(:user) }
    context "when requesting JSON" do
      render_views
      before do
        sign_in user
      end
      context "when requesting via SSL" do
        it "returns HTTPS paths" do
          resource = FactoryGirl.create(:complete_scanned_resource)
          allow(request).to receive(:ssl?).and_return(true)

          get :manifest, params: { id: resource.id, format: :json }

          expect(response).to be_success
          response_json = JSON.parse(response.body)
          expect(response_json['@id']).to eq "http://plum.com/concern/scanned_resources/#{resource.id}/manifest"
        end
      end
      context "when requesting a child resource" do
        it "returns a manifest" do
          resource = FactoryGirl.create(:complete_scanned_resource)
          allow(resource).to receive(:id).and_return("resource")
          solr.add resource.to_solr.merge(ordered_by_ssim: ["work"])
          solr.commit

          get :manifest, params: { id: "resource", format: :json }

          expect(response).to be_success
        end
      end
      it "builds a manifest" do
        resource = FactoryGirl.create(:complete_scanned_resource)
        resource_2 = FactoryGirl.create(:complete_scanned_resource)
        allow(resource).to receive(:id).and_return("test")
        allow(resource_2).to receive(:id).and_return("test2")
        solr.add resource.to_solr
        solr.add resource_2.to_solr
        solr.commit
        expect(ScannedResource).not_to receive(:find)

        get :manifest, params: { id: "test2", format: :json }

        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['@id']).to eq "http://plum.com/concern/scanned_resources/test2/manifest"
        expect(response_json["service"]).to eq nil
      end
    end
  end

  describe 'update' do
    let(:scanned_resource_attributes) { { portion_note: 'Section 2', description: 'a description', source_metadata_identifier: '2028405' } }
    before do
      sign_in user
    end
    context 'by default' do
      it 'updates the record but does not refresh the exernal metadata' do
        post :update, params: { id: scanned_resource, scanned_resource: scanned_resource_attributes }
        expect(reloaded.portion_note).to eq 'Section 2'
        expect(reloaded.title).to eq ['Dummy Title']
        expect(reloaded.description).to eq 'a description'
      end
      it "can update the start_canvas" do
        post :update, params: { id: scanned_resource, scanned_resource: { start_canvas: "1" } }
        expect(reloaded.start_canvas).to eq "1"
      end
      context "when in a collection" do
        let(:scanned_resource) { FactoryGirl.create(:scanned_resource_in_collection, user: user) }
        it "doesn't remove the item from collections" do
          patch :update, params: { id: scanned_resource, scanned_resource: { ocr_language: [], viewing_hint: "individuals", viewing_direction: "left-to-right" } }
          expect(reloaded.member_of_collections).not_to be_blank
        end
      end
      it "posts an update event" do
        manifest_generator = instance_double(ManifestEventGenerator, record_updated: true)
        allow(ManifestEventGenerator).to receive(:new).and_return(manifest_generator)

        post :update, params: { id: scanned_resource, scanned_resource: scanned_resource_attributes }

        expect(manifest_generator).to have_received(:record_updated).with(scanned_resource)
      end
    end
    context 'when :refresh_remote_metadata is set', vcr: { cassette_name: 'bibdata', allow_playback_repeats: true } do
      it 'updates remote metadata' do
        allow(Ezid::Identifier).to receive(:modify)
        allow(Ezid::Client.config).to receive(:user).and_return("test")
        post :update, params: { id: scanned_resource, scanned_resource: scanned_resource_attributes, refresh_remote_metadata: true }
        expect(reloaded.title.first.to_s).to eq 'The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.'
        expect(Ezid::Identifier).to have_received(:modify)
      end
    end
    context "when ocr_language is set" do
      let(:scanned_resource_attributes) do
        {
          ocr_language: ["eng"]
        }
      end

      let(:scanned_resource) do
        s = FactoryGirl.build(:scanned_resource, user: user, title: ['Dummy Title'])
        s.ordered_members << file_set
        s.save
        s
      end
      let(:file_set) { FactoryGirl.create(:file_set) }

      around { |example| perform_enqueued_jobs(&example) }

      it "updates OCR on file sets" do
        ocr_runner = instance_double(OCRRunner)
        allow(OCRRunner).to receive(:new).and_return(ocr_runner)
        allow(ocr_runner).to receive(:from_file)

        post :update, params: { id: scanned_resource, scanned_resource: scanned_resource_attributes }

        expect(OCRRunner).to have_received(:new).with(file_set)
      end
    end
    context "with collections" do
      let(:resource) { FactoryGirl.create(:scanned_resource_in_collection, user: user) }
      let(:col2) { FactoryGirl.create(:collection, user: user, title: ['Col 2']) }

      before do
        col2.save
      end

      it "updates collection membership" do
        expect(resource.member_of_collections).to_not be_empty

        updated_attributes = resource.attributes
        updated_attributes[:member_of_collection_ids] = [col2.id]
        post :update, params: { id: resource, scanned_resource: updated_attributes }
        expect(resource.reload.member_of_collections).to eq [col2]
      end
    end
  end

  describe "viewing direction and hint" do
    let(:scanned_resource) { FactoryGirl.build(:scanned_resource) }
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
      scanned_resource.save!
    end
    it "updates metadata" do
      post :update, params: { id: scanned_resource.id, scanned_resource: { viewing_hint: 'continuous', viewing_direction: 'bottom-to-top' } }
      scanned_resource.reload
      expect(scanned_resource.viewing_direction).to eq 'bottom-to-top'
      expect(scanned_resource.viewing_hint).to eq 'continuous'
    end
  end

  describe "show" do
    before do
      sign_in user if user
    end
    context "when the user is anonymous" do
      let(:user) { nil }
      context "and the work's incomplete" do
        it "redirects for auth" do
          resource = FactoryGirl.create(:pending_scanned_resource)

          get :show, params: { id: resource.id }

          expect(response).to be_redirect
        end
      end
      context "and the work's flagged" do
        it "works" do
          resource = FactoryGirl.create(:flagged_scanned_resource)

          get :show, params: { id: resource.id }

          expect(response).to be_success
        end
      end
      context "and the work's complete" do
        it "works" do
          resource = FactoryGirl.create(:complete_scanned_resource)

          get :show, params: { id: resource.id }

          expect(response).to be_success
        end
      end
    end
    context "when the user's an admin" do
      let(:user) { FactoryGirl.create(:admin) }
      context "and the work's incomplete" do
        it "works" do
          resource = FactoryGirl.create(:pending_scanned_resource)

          get :show, params: { id: resource.id }

          expect(response).to be_success
        end
      end
    end
    context "when there's a parent" do
      it "is a success" do
        resource = FactoryGirl.create(:complete_scanned_resource)
        work = FactoryGirl.build(:multi_volume_work)
        work.ordered_members << resource
        work.save
        resource.update_index

        get :show, params: { id: resource.id }

        expect(response).to be_success
      end
    end
  end

  describe 'pdf' do
    before do
      sign_in user if sign_in_user
    end
    context "when requesting color" do
      context "and given permission" do
        let(:user) { FactoryGirl.create(:admin) }
        let(:sign_in_user) { user }
        it "works" do
          pdf = double("Actor")
          allow(ScannedResourcePDF).to receive(:new).with(anything, quality: "color").and_return(pdf)
          allow(pdf).to receive(:render).and_return(true)
          get :pdf, params: { id: scanned_resource, pdf_quality: "color" }
          expect(response).to redirect_to(ManifestBuilder::HyraxManifestHelper.new.download_path(scanned_resource, file: 'color-pdf', locale: 'en'))
        end
        context "when not given permission" do
          let(:user) { FactoryGirl.create(:campus_patron) }
          let(:sign_in_user) { user }
          context "and color PDF is enabled" do
            let(:scanned_resource) { FactoryGirl.create(:complete_scanned_resource, user: user, title: ['Dummy Title'], pdf_type: ['color']) }
            it "works" do
              pdf = double("Actor")
              allow(ScannedResourcePDF).to receive(:new).with(anything, quality: "color").and_return(pdf)
              allow(pdf).to receive(:render).and_return(true)

              get :pdf, params: { id: scanned_resource, pdf_quality: "color" }

              expect(response).to redirect_to(ManifestBuilder::HyraxManifestHelper.new.download_path(scanned_resource, file: 'color-pdf', locale: 'en'))
            end
          end
          it "doesn't work" do
            get :pdf, params: { id: scanned_resource, pdf_quality: "color" }

            expect(response).to redirect_to "/?locale=en"
          end
        end
      end
    end
    context "when requesting gray" do
      let(:sign_in_user) { nil }
      context "when given permission" do
        it 'generates the pdf then redirects to its download url' do
          pdf = double("Actor")
          allow(ScannedResourcePDF).to receive(:new).with(anything, quality: "gray").and_return(pdf)
          allow(pdf).to receive(:render).and_return(true)
          get :pdf, params: { id: scanned_resource, pdf_quality: "gray" }
          expect(response).to redirect_to(ManifestBuilder::HyraxManifestHelper.new.download_path(scanned_resource, file: 'gray-pdf', locale: 'en'))
        end
      end
      context "when the resource has no pdf type set" do
        let(:sign_in_user) { FactoryGirl.create(:user) }
        let(:scanned_resource) { FactoryGirl.create(:complete_scanned_resource, user: user, title: ['Dummy Title'], pdf_type: []) }
        it "redirects to root" do
          get :pdf, params: { id: scanned_resource, pdf_quality: "gray" }

          expect(response).to redirect_to Rails.application.class.routes.url_helpers.root_path(locale: 'en')
        end
      end
      context "when not given permission" do
        let(:scanned_resource) { FactoryGirl.create(:private_scanned_resource, title: ['Dummy Title']) }
        context "and not logged in" do
          it "redirects for auth" do
            get :pdf, params: { id: scanned_resource, pdf_quality: "gray" }

            expect(response).to redirect_to "http://test.host/users/auth/cas?locale=en"
          end
        end
        context "and logged in" do
          let(:sign_in_user) { FactoryGirl.create(:user) }
          it "redirects to root" do
            get :pdf, params: { id: scanned_resource, pdf_quality: "gray" }

            expect(response).to redirect_to Rails.application.class.routes.url_helpers.root_path(locale: 'en')
          end
        end
      end
    end
  end

  describe "#browse_everything_files" do
    let(:resource) { FactoryGirl.create(:scanned_resource, user: user) }
    let(:file) { File.open(Rails.root.join("spec", "fixtures", "files", "color.tif")) }
    let(:user) { FactoryGirl.create(:admin) }
    let(:params) do
      {
        "selected_files" => {
          "0" => {
            "url" => "file://#{file.path}",
            "file_name" => File.basename(file.path),
            "file_size" => file.size
          }
        }
      }
    end
    let(:stub) {}
    before do
      sign_in user
      allow(CharacterizeJob).to receive(:perform_later)
    end
    around { |example| perform_enqueued_jobs(&example) }
    it "appends a new file set" do
      post :browse_everything_files, params: { id: resource.id, selected_files: params["selected_files"] }
      reloaded = resource.reload
      expect(reloaded.file_sets.length).to eq 1
      expect(reloaded.file_sets.first.files.first.original_name).to eq "color.tif"
      path = Rails.application.class.routes.url_helpers.file_manager_hyrax_scanned_resource_path(resource)
      expect(response).to redirect_to path
      expect(reloaded.pending_uploads.length).to eq 0
    end
    context "when there's a parent id" do
      it "redirects to the parent path" do
        allow(BrowseEverythingIngestJob).to receive(:perform_later).and_return(true)
        post :browse_everything_files, params: { id: resource.id, selected_files: params["selected_files"], parent_id: resource.id }
        path = Rails.application.class.routes.url_helpers.file_manager_hyrax_parent_scanned_resource_path(id: resource.id, parent_id: resource.id)
        expect(response).to redirect_to path
      end
    end
    context "when the job hasn't run yet" do
      it "creates pending uploads" do
        allow(BrowseEverythingIngestJob).to receive(:perform_later).and_return(true)
        post :browse_everything_files, params: { id: resource.id, selected_files: params["selected_files"] }
        expect(resource.pending_uploads.length).to eq 1
        pending_upload = resource.pending_uploads.first
        expect(pending_upload.file_name).to eq File.basename(file.path)
        expect(pending_upload.file_path).to eq file.path
        expect(pending_upload.upload_set_id).not_to be_blank
      end
      it "doesn't delete the pending upload until after file is in Fedora" do
        allow(IngestFileJob).to receive(:perform_later).and_return(true)
        post :browse_everything_files, params: { id: resource.id, selected_files: params["selected_files"] }
        expect(resource.pending_uploads.length).to eq 1
      end
    end
  end

  describe "#form_class" do
    subject { described_class.new.form_class }
    it { is_expected.to eq Hyrax::ScannedResourceForm }
  end

  include_examples "structure persister", :scanned_resource, ScannedResourceShowPresenter
end
