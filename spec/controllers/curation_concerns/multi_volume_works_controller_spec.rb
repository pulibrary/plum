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
end
