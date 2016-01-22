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

  include_examples "structure persister", :multi_volume_work, MultiVolumeWorkShowPresenter
end
