require 'rails_helper'

RSpec.describe CollectionsController do
  describe "#manifest" do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
    end
    it "returns a manifest for the collection" do
      coll = FactoryGirl.create(:collection)
      allow(ManifestBuilder).to receive(:new).and_call_original

      get :manifest, id: coll.id, format: :json

      expect(ManifestBuilder).to have_received(:new)
      expect(response).to be_success
    end
  end
end
