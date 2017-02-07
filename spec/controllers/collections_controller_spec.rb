require 'rails_helper'

RSpec.describe CollectionsController do
  describe "#manifest" do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user if user
    end
    it "returns a manifest for the collection" do
      coll = FactoryGirl.create(:collection)
      allow(ManifestBuilder).to receive(:new).and_call_original

      get :manifest, params: { id: coll.id, format: :json }

      expect(ManifestBuilder).to have_received(:new)
      expect(response).to be_success
    end

    context "when not logged in" do
      let(:user) {}
      it "returns a manifest for a public collection" do
        coll = FactoryGirl.create(:collection)

        get :manifest, params: { id: coll.id, format: :json }

        expect(response).to be_success
      end
      it "returns unauthorized for a collection they don't have access to" do
        coll = FactoryGirl.create(:private_collection)

        get :manifest, params: { id: coll.id, format: :json }

        expect(response).to redirect_to "/users/auth/cas?locale=en"
      end
    end
  end

  describe "#index_manifest" do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user if user
    end
    it "returns a manifest for all collections" do
      FactoryGirl.create(:collection)
      allow(AllCollectionsManifestBuilder).to receive(:new).and_call_original

      get :index_manifest, params: { format: :json }

      expect(AllCollectionsManifestBuilder).to have_received(:new).with(nil, ability: anything, ssl: false)
      expect(response).to be_success
    end
    context "if not signed in" do
      let(:user) { nil }
      it "returns all public collections" do
        FactoryGirl.create(:collection)
        FactoryGirl.create(:private_collection)

        get :index_manifest, params: { format: :json }

        expect(response).to be_success
        json = IIIF::Service.parse(response.body)
        expect(json.collections.length).to eq 1
      end
    end
  end
end
