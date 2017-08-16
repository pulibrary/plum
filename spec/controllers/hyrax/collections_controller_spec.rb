require 'rails_helper'

RSpec.describe Hyrax::CollectionsController do
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

    context 'when the manifest is empty or invalid' do
      let(:coll) { FactoryGirl.create(:collection) }
      let(:image_work) { FactoryGirl.create(:image_work) }
      let(:file_set) { FactoryGirl.create(:file_set, id: 'x633f104m') }
      let(:manifest) { instance_double(IIIF::Presentation::Manifest) }
      render_views
      before do
        sign_in user
        image_work.ordered_members << file_set
        image_work.thumbnail_id = file_set.id
        image_work.save
        file_set.update_index
        coll.ordered_members << image_work
        coll.thumbnail_id = image_work.id
        coll.save
        image_work.update_index
      end

      it 'returns an error message' do
        allow(manifest).to receive(:to_json).and_return("{}")
        allow(ManifestBuilder).to receive(:new).and_return(manifest)

        get :manifest, params: { id: coll.id, format: :json }

        response_json = JSON.parse(response.body)
        expect(response_json).to be_empty
      end
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
      context "and an authentication token is given" do
        it "renders the full manifest" do
          coll = FactoryGirl.create(:private_collection)
          authorization_token = AuthToken.create(groups: ["completer"])
          get :manifest, params: { id: coll.id, format: :json, auth_token: authorization_token.token }

          expect(response.status).to eq 200
          expect(response.body).not_to eq "{}"
        end
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
