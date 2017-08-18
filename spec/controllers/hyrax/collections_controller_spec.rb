require 'rails_helper'

RSpec.describe Hyrax::CollectionsController do
  describe "#manifest" do
    let(:user) { FactoryGirl.create(:admin) }

    before do
      sign_in user if user
    end

    it "returns a manifest for the collection" do
      coll = FactoryGirl.create(:collection)

      get :manifest, params: { id: coll.id, format: :json }

      expect(response.status).to eq 200
      expect(response.body).not_to be_empty
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

      it 'returns a 404 status for empty manifests' do
        allow(manifest).to receive(:to_json).and_return("{}")
        allow(SparseMemberCollectionManifest).to receive(:new).and_return(manifest)

        get :manifest, params: { id: coll.id, format: :json }

        expect(response.status).to eq 404
        response_json = JSON.parse(response.body)
        expect(response_json).to be_empty
      end

      it 'returns an error message for invalid manifests' do
        allow(SparseMemberCollectionManifest).to receive(:new).and_raise(StandardError)

        get :manifest, params: { id: coll.id, format: :json }

        expect(response.status).to eq 500
        response_json = JSON.parse(response.body)
        expect(response_json).to include "message" => I18n.t('works.show.no_image')
      end
    end

    context "when not logged in" do
      let(:user) {}
      it "returns a manifest for a public collection" do
        coll = FactoryGirl.create(:collection)

        get :manifest, params: { id: coll.id, format: :json }

        expect(response.status).to eq 200
        expect(response.body).not_to be_empty
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

  describe "#index_manifest", manifest: true do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user if user
    end
    it "returns a manifest for all collections" do
      FactoryGirl.create(:collection)

      get :index_manifest, params: { format: :json }

      expect(response.status).to eq 200
      expect(response.body).not_to be_empty
    end
    context "if not signed in" do
      let(:user) { nil }
      it "returns all public collections" do
        FactoryGirl.create(:collection)
        FactoryGirl.create(:private_collection)

        get :index_manifest, params: { format: :json }

        expect(response.status).to eq 200
        json = IIIF::Service.parse(response.body)
        expect(json.collections.length).to eq 1
      end
    end
  end
end
