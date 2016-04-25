require 'rails_helper'

describe CurationConcerns::ScannedResourcesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:scanned_resource) { FactoryGirl.create(:scanned_resource, user: user, title: ['Dummy Title']) }
  let(:reloaded) { scanned_resource.reload }

  describe "delete" do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
    end

    it "deletes a record" do
      s = FactoryGirl.create(:scanned_resource)

      delete :destroy, id: s.id

      expect(ScannedResource.all.length).to eq 0
    end

    it "fires a delete event" do
      s = FactoryGirl.create(:scanned_resource)
      manifest_generator = instance_double(ManifestEventGenerator, record_deleted: true)
      allow(ManifestEventGenerator).to receive(:new).and_return(manifest_generator)

      delete :destroy, id: s.id

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
        post :create, scanned_resource: scanned_resource_attributes
        s = ScannedResource.last
        expect(s.title).to eq ['The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.']
      end
      it "posts a creation event to the queue" do
        manifest_generator = instance_double(ManifestEventGenerator, record_created: true, record_updated: true)
        allow(ManifestEventGenerator).to receive(:new).and_return(manifest_generator)

        post :create, scanned_resource: scanned_resource_attributes

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
          post :create, scanned_resource: scanned_resource_attributes
        end.not_to change { ScannedResource.count }
        expect(response.status).to be 422
      end
      it "doesn't post a creation event" do
        manifest_generator = instance_double(ManifestEventGenerator, record_created: true)
        allow(ManifestEventGenerator).to receive(:new).and_return(manifest_generator)

        post :create, scanned_resource: scanned_resource_attributes

        expect(manifest_generator).not_to have_received(:record_created)
      end
    end

    context "when given a parent" do
      let(:parent) { FactoryGirl.create(:multi_volume_work, user: user) }
      let(:scanned_resource_attributes) do
        FactoryGirl.attributes_for(:scanned_resource).except(:source_metadata_identifier)
      end
      it "creates and indexes its parent" do
        post :create, scanned_resource: scanned_resource_attributes, parent_id: parent.id
        solr_document = ActiveFedora::SolrService.query("id:#{assigns[:curation_concern].id}").first

        expect(solr_document["ordered_by_ssim"]).to eq [parent.id]
      end
    end

    context "when selecting a collection" do
      let(:collection) { FactoryGirl.create(:collection, user: user) }
      let(:scanned_resource_attributes) do
        FactoryGirl.attributes_for(:scanned_resource).except(:source_metadata_identifier).merge(
          collection_ids: [collection.id]
        )
      end
      it "successfully add the resource to the collection" do
        post :create, scanned_resource: scanned_resource_attributes
        s = ScannedResource.last
        expect(s.in_collections).to eq [collection]
      end
      it "posts the collection slugs to the event endpoint" do
        messaging_client = instance_double(MessagingClient, publish: true)
        manifest_generator = ManifestEventGenerator.new(messaging_client)
        allow(ManifestEventGenerator).to receive(:new).and_return(manifest_generator)

        post :create, scanned_resource: scanned_resource_attributes

        s = ScannedResource.last

        expect(messaging_client).to have_received(:publish).with(
          {
            "id" => s.id,
            "event" => "CREATED",
            "manifest_url" => "http://plum.com/concern/scanned_resources/#{s.id}/manifest",
            "collection_slugs" => s.in_collections.map(&:exhibit_id)
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
          resource = FactoryGirl.build(:scanned_resource)
          allow(resource).to receive(:id).and_return("test")
          solr.add resource.to_solr
          solr.commit

          allow(request).to receive(:ssl?).and_return(true)
          get :manifest, id: "test", format: :json

          expect(response).to be_success
          response_json = JSON.parse(response.body)
          expect(response_json['@id']).to eq "https://plum.com/concern/scanned_resources/test/manifest"
        end
      end
      context "when requesting a child resource" do
        it "returns a manifest" do
          resource = FactoryGirl.build(:scanned_resource)
          allow(resource).to receive(:id).and_return("resource")
          solr.add resource.to_solr.merge(ordered_by_ssim: ["work"])
          solr.commit

          get :manifest, id: "resource", format: :json

          expect(response).to be_success
        end
      end
      it "builds a manifest" do
        resource = FactoryGirl.build(:scanned_resource)
        resource_2 = FactoryGirl.build(:scanned_resource)
        allow(resource).to receive(:id).and_return("test")
        allow(resource_2).to receive(:id).and_return("test2")
        solr.add resource.to_solr
        solr.add resource_2.to_solr
        solr.commit
        expect(ScannedResource).not_to receive(:find)

        get :manifest, id: "test2", format: :json

        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['@id']).to eq "http://plum.com/concern/scanned_resources/test2/manifest"
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
        post :update, id: scanned_resource, scanned_resource: scanned_resource_attributes
        expect(reloaded.portion_note).to eq 'Section 2'
        expect(reloaded.title).to eq ['Dummy Title']
        expect(reloaded.description).to eq 'a description'
      end
      it "posts an update event" do
        manifest_generator = instance_double(ManifestEventGenerator, record_updated: true)
        allow(ManifestEventGenerator).to receive(:new).and_return(manifest_generator)

        post :update, id: scanned_resource, scanned_resource: scanned_resource_attributes

        expect(manifest_generator).to have_received(:record_updated).with(scanned_resource)
      end
    end
    context 'when :refresh_remote_metadata is set', vcr: { cassette_name: 'bibdata', allow_playback_repeats: true } do
      it 'updates remote metadata' do
        post :update, id: scanned_resource, scanned_resource: scanned_resource_attributes, refresh_remote_metadata: true
        expect(reloaded.title).to eq ['The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.']
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
      it "updates OCR on file sets" do
        ocr_runner = instance_double(OCRRunner)
        allow(OCRRunner).to receive(:new).and_return(ocr_runner)
        allow(ocr_runner).to receive(:from_datastream)

        post :update, id: scanned_resource, scanned_resource: scanned_resource_attributes

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
        expect(resource.in_collections).to_not be_empty

        updated_attributes = resource.attributes
        updated_attributes[:collection_ids] = [col2.id]
        post :update, id: resource, scanned_resource: updated_attributes
        expect(resource.reload.in_collections).to eq [col2]
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
      post :update, id: scanned_resource.id, scanned_resource: { viewing_hint: 'continuous', viewing_direction: 'bottom-to-top' }
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
          resource = FactoryGirl.create(:scanned_resource, state: 'pending')

          get :show, id: resource.id

          expect(response).to be_redirect
        end
      end
      context "and the work's flagged" do
        it "works" do
          resource = FactoryGirl.create(:open_scanned_resource, state: 'flagged')

          get :show, id: resource.id

          expect(response).to be_success
        end
      end
      context "and the work's complete" do
        it "works" do
          resource = FactoryGirl.create(:open_scanned_resource, state: 'complete')

          get :show, id: resource.id

          expect(response).to be_success
        end
      end
    end
    context "when the user's an admin" do
      let(:user) { FactoryGirl.create(:admin) }
      context "and the work's incomplete" do
        it "works" do
          resource = FactoryGirl.create(:open_scanned_resource, state: 'pending')

          get :show, id: resource.id

          expect(response).to be_success
        end
      end
    end
    context "when there's a parent" do
      it "is a success" do
        resource = FactoryGirl.create(:scanned_resource)
        work = FactoryGirl.build(:multi_volume_work)
        work.ordered_members << resource
        work.save
        resource.update_index

        get :show, id: resource.id

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
          get :pdf, id: scanned_resource, pdf_quality: "color"
          expect(response).to redirect_to(Rails.application.class.routes.url_helpers.download_path(scanned_resource, file: 'color-pdf'))
        end
        context "when not given permission" do
          let(:user) { FactoryGirl.create(:campus_patron) }
          let(:sign_in_user) { user }
          context "and color PDF is enabled" do
            let(:scanned_resource) { FactoryGirl.create(:scanned_resource, user: user, title: ['Dummy Title'], pdf_type: ['color']) }
            it "works" do
              pdf = double("Actor")
              allow(ScannedResourcePDF).to receive(:new).with(anything, quality: "color").and_return(pdf)
              allow(pdf).to receive(:render).and_return(true)

              get :pdf, id: scanned_resource, pdf_quality: "color"

              expect(response).to redirect_to(Rails.application.class.routes.url_helpers.download_path(scanned_resource, file: 'color-pdf'))
            end
          end
          it "doesn't work" do
            get :pdf, id: scanned_resource, pdf_quality: "color"

            expect(response).to redirect_to "/"
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
          get :pdf, id: scanned_resource, pdf_quality: "gray"
          expect(response).to redirect_to(Rails.application.class.routes.url_helpers.download_path(scanned_resource, file: 'gray-pdf'))
        end
      end
      context "when the resource has no pdf type set" do
        let(:sign_in_user) { FactoryGirl.create(:user) }
        let(:scanned_resource) { FactoryGirl.create(:scanned_resource, user: user, title: ['Dummy Title'], pdf_type: []) }
        it "redirects to root" do
          get :pdf, id: scanned_resource, pdf_quality: "gray"

          expect(response).to redirect_to Rails.application.class.routes.url_helpers.root_path
        end
      end
      context "when not given permission" do
        let(:scanned_resource) { FactoryGirl.create(:private_scanned_resource, title: ['Dummy Title']) }
        context "and not logged in" do
          it "redirects for auth" do
            get :pdf, id: scanned_resource, pdf_quality: "gray"

            expect(response).to redirect_to "http://test.host/users/auth/cas"
          end
        end
        context "and logged in" do
          let(:sign_in_user) { FactoryGirl.create(:user) }
          it "redirects to root" do
            get :pdf, id: scanned_resource, pdf_quality: "gray"

            expect(response).to redirect_to Rails.application.class.routes.url_helpers.root_path
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
    it "appends a new file set" do
      post :browse_everything_files, id: resource.id, selected_files: params["selected_files"]
      reloaded = resource.reload
      expect(reloaded.file_sets.length).to eq 1
      expect(reloaded.file_sets.first.files.first.mime_type).to eq "image/tiff"
      path = Rails.application.class.routes.url_helpers.file_manager_curation_concerns_scanned_resource_path(resource)
      expect(response).to redirect_to path
      expect(reloaded.pending_uploads.length).to eq 0
    end
    context "when the job hasn't run yet" do
      it "creates pending uploads" do
        allow(BrowseEverythingIngestJob).to receive(:perform_later).and_return(true)
        post :browse_everything_files, id: resource.id, selected_files: params["selected_files"]
        expect(resource.pending_uploads.length).to eq 1
        pending_upload = resource.pending_uploads.first
        expect(pending_upload.file_name).to eq File.basename(file.path)
        expect(pending_upload.file_path).to eq file.path
        expect(pending_upload.upload_set_id).not_to be_blank
      end
      it "doesn't delete the pending upload until after file is in Fedora" do
        allow(IngestFileJob).to receive(:perform_later).and_return(true)
        post :browse_everything_files, id: resource.id, selected_files: params["selected_files"]
        expect(resource.pending_uploads.length).to eq 1
      end
    end
  end

  include_examples "structure persister", :scanned_resource, ScannedResourceShowPresenter

  describe "#flag" do
    context "a complete object with an existing workflow note" do
      let(:scanned_resource) { FactoryGirl.create(:scanned_resource, user: user, state: 'complete', workflow_note: ['Existing note']) }
      let(:flag_attributes) { { workflow_note: 'Page 4 is broken' } }
      let(:reloaded) { ScannedResource.find scanned_resource.id }
      before do
        sign_in user
      end

      it "updates the state" do
        post :flag, id: scanned_resource.id, scanned_resource: flag_attributes
        expect(response.status).to eq 302
        expect(flash[:notice]).to eq 'Resource updated'

        expect(reloaded.state).to eq 'flagged'
        expect(reloaded.workflow_note).to include 'Existing note', 'Page 4 is broken'
      end
    end
    context "a complete object without a workflow note" do
      let(:scanned_resource) { FactoryGirl.create(:scanned_resource, user: user, state: 'complete') }
      let(:flag_attributes) { { workflow_note: 'Page 4 is broken' } }
      let(:reloaded) { ScannedResource.find scanned_resource.id }
      before do
        sign_in user
      end

      it "updates the state" do
        post :flag, id: scanned_resource.id, scanned_resource: flag_attributes
        expect(response.status).to eq 302
        expect(flash[:notice]).to eq 'Resource updated'

        expect(reloaded.state).to eq 'flagged'
        expect(reloaded.workflow_note).to include 'Page 4 is broken'
      end
    end
    context "a pending object" do
      let(:scanned_resource) { FactoryGirl.create(:scanned_resource, user: user, state: 'pending') }
      let(:flag_attributes) { { workflow_note: 'Page 4 is broken' } }
      let(:reloaded) { ScannedResource.find scanned_resource.id }
      before do
        sign_in user
      end

      it "receives an error" do
        post :flag, id: scanned_resource.id, scanned_resource: flag_attributes
        expect(response.status).to eq 302
        expect(flash[:alert]).to eq 'Unable to update resource'
        expect(reloaded.state).to eq 'pending'
      end
    end
  end

  describe "marking complete" do
    let(:scanned_resource) { FactoryGirl.create(:scanned_resource, user: user, state: 'final_review') }
    let(:scanned_resource_attributes) { { state: 'complete' } }
    let(:reloaded) { ScannedResource.find scanned_resource.id }

    context "as an admin" do
      let(:admin) { FactoryGirl.create(:admin) }
      before do
        sign_in admin
        Ezid::Client.configure do |conf| conf.logger = Logger.new(File::NULL); end
      end

      it "succeeds", vcr: { cassette_name: "ezid" } do
        post :update, id: scanned_resource.id, scanned_resource: scanned_resource_attributes
        expect(reloaded.state).to eq 'complete'
      end
    end
    context "as an image editor" do
      before do
        sign_in user
      end

      it "fails" do
        post :update, id: scanned_resource.id, scanned_resource: scanned_resource_attributes
        expect(flash[:alert]).to eq 'Unable to mark resource complete'
        expect(reloaded.state).to eq 'final_review'
      end
    end
  end
end
