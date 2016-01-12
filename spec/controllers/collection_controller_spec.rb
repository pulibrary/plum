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

  describe "#index_manifest" do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
    end
    it "returns a manifest for all collections" do
      FactoryGirl.create(:collection)
      allow(AllCollectionsManifestBuilder).to receive(:new).and_call_original

      get :index_manifest, format: :json

      expect(AllCollectionsManifestBuilder).to have_received(:new).with(nil, ssl: false)
      expect(response).to be_success
    end
  end
end
