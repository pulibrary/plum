# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work MultiVolumeWork`
require 'rails_helper'

describe Hyrax::MultiVolumeWorksController, admin_set: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:multi_volume_work) { FactoryGirl.create(:multi_volume_work, user: user, title: ['Dummy Title']) }

  describe "create" do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
    end
    context "when given a bib id", vcr: { cassette_name: 'bibdata', allow_playback_repeats: true } do
      let(:multi_volume_work_attributes) do
        FactoryGirl.attributes_for(:multi_volume_work).merge(
          source_metadata_identifier: "2028405",
          rights_statement: "http://rightsstatements.org/vocab/NKC/1.0/"
        )
      end
      it "updates the metadata" do
        post :create, params: { multi_volume_work: multi_volume_work_attributes }
        s = MultiVolumeWork.last
        expect(s.title.first.to_s).to eq 'The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.'
      end
    end
  end

  describe "update" do
    let(:user) { FactoryGirl.create(:admin) }

    before do
      sign_in user
    end

    context "when an error occurs" do
      let(:mvw) { FactoryGirl.create :multi_volume_work }
      let(:actor) { instance_double('Actor') }
      before do
        allow(controller).to receive(:actor).and_return(actor)
        allow(actor).to receive(:update).and_return(false)
      end
      it "does not update the object" do
        expect {
          post :update, params: { id: mvw.id, multi_volume_work: { member_of_collection_ids: ['foo'] } }
        }.not_to change { mvw.date_modified }
      end
    end

    context "when changing visibility" do
      let(:mvw) { FactoryGirl.create :multi_volume_work_with_volume }
      it "ask to copy visibility to attached volumes" do
        post :update, params: { id: mvw.id, multi_volume_work: { visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE } }
        expect(response).to redirect_to "http://test.host/concern/confirm/#{mvw.id}/visibility?locale=en"
      end
    end
  end

  describe "#browse_everything_files" do
    around { |example| perform_enqueued_jobs(&example) }
    let(:resource) { FactoryGirl.create(:multi_volume_work, user: user) }
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
      allow(CharacterizeJob).to receive(:perform_later).once
      allow(BrowseEverythingIngestJob).to receive(:perform_later).and_return(true) if stub
      post :browse_everything_files, params: { id: resource.id, selected_files: params["selected_files"] }
    end
    it "appends a new file set" do
      reloaded = resource.reload
      expect(reloaded.file_sets.length).to eq 1
      first_file = reloaded.file_sets.first.files.first
      expect(first_file.original_name).to eq "color.tif"
      expect(first_file.mime_type).to eq "message/external-body;access-type=URL;url=\"http://plum.com/downloads/#{reloaded.file_sets.first.id}\""
      path = Rails.application.class.routes.url_helpers.file_manager_hyrax_multi_volume_work_path(resource)
      expect(response).to redirect_to path
      expect(reloaded.pending_uploads.length).to eq 0
    end
  end

  include_examples "structure persister", :multi_volume_work, MultiVolumeWorkShowPresenter
end
