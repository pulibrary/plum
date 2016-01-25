# Generated via
#  `rails generate curation_concerns:work MultiVolumeWork`
require 'rails_helper'

describe CurationConcerns::MultiVolumeWorksController do
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
          source_metadata_identifier: "2028405"
        )
      end
      it "updates the metadata" do
        post :create, multi_volume_work: multi_volume_work_attributes
        s = MultiVolumeWork.last
        expect(s.title).to eq ['The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.']
      end
    end
  end

  describe "#bulk-edit" do
    let(:user) { FactoryGirl.create(:image_editor) }
    before do
      sign_in user
    end
    let(:solr) { ActiveFedora.solr.conn }
    it "sets @members" do
      mvw = FactoryGirl.create(:multi_volume_work_with_volume, user: user)
      resource = mvw.members.first
      mvw.save
      resource.save
      get :bulk_edit, id: mvw.id

      expect(assigns(:curation_concern)).to eq mvw
      expect(assigns(:members).map(&:id)).to eq [resource.id]
    end
  end

  describe "#save_order" do
    let(:resource) { FactoryGirl.create(:multi_volume_work, user: user) }
    let(:member) { FactoryGirl.create(:scanned_resource, user: user) }
    let(:member_2) { FactoryGirl.create(:scanned_resource, user: user) }
    let(:new_order) { resource.ordered_member_ids }
    let(:user) { FactoryGirl.create(:admin) }
    render_views
    before do
      3.times { resource.ordered_members << member }
      resource.ordered_members << member_2
      resource.save
      sign_in user
      post :save_order, id: resource.id, order: new_order, format: :json
    end

    context "when given a new order" do
      let(:new_order) { [member.id, member.id, member_2.id, member.id] }
      it "applies it" do
        expect(response).to be_success
        expect(resource.reload.ordered_member_ids).to eq new_order
      end
    end

    context "when given an incomplete order" do
      let(:new_order) { [member.id] }
      it "fails and gives an error" do
        expect(response).not_to be_success
        expect(JSON.parse(response.body)["message"]).to eq "Order given has the wrong number of elements (should be 4)"
        expect(response).to be_bad_request
      end
    end
  end

  describe "#browse_everything_files" do
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
      post :browse_everything_files, id: resource.id, selected_files: params["selected_files"]
    end
    it "appends a new file set" do
      reloaded = resource.reload
      expect(reloaded.file_sets.length).to eq 1
      expect(reloaded.file_sets.first.files.first.mime_type).to eq "image/tiff"
      path = Rails.application.class.routes.url_helpers.bulk_edit_curation_concerns_multi_volume_work_path(resource)
      expect(response).to redirect_to path
      expect(reloaded.pending_uploads.length).to eq 0
    end
  end

  include_examples "structure persister", :multi_volume_work, MultiVolumeWorkShowPresenter
end
