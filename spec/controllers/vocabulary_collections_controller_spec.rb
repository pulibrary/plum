require 'rails_helper'

RSpec.describe VocabularyCollectionsController, type: :controller do
  let(:vocabulary) { FactoryGirl.create(:vocabulary) }
  let(:user) { FactoryGirl.create(:admin) }

  before do
    sign_in user
  end

  # This should return the minimal set of attributes required to create a valid
  # VocabularyCollection. As you add validations to VocabularyCollection, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { label: 'Collection 1', vocabulary_id: vocabulary.id } }

  let(:invalid_attributes) { { label: nil, vocabulary_id: nil } }

  describe "GET #index" do
    it "assigns all vocabulary_collections as @vocabulary_collections" do
      vocabulary_collection = VocabularyCollection.create! valid_attributes
      get :index, params: {}
      expect(assigns(:vocabulary_collections)).to eq([vocabulary_collection])
    end
  end

  describe "GET #show" do
    it "assigns the requested vocabulary_collection as @vocabulary_collection" do
      vocabulary_collection = VocabularyCollection.create! valid_attributes
      get :show, params: { id: vocabulary_collection.to_param }
      expect(assigns(:vocabulary_collection)).to eq(vocabulary_collection)
    end
  end

  describe "GET #new" do
    it "assigns a new vocabulary_collection as @vocabulary_collection" do
      get :new, params: {}
      expect(assigns(:vocabulary_collection)).to be_a_new(VocabularyCollection)
    end
  end

  describe "GET #edit" do
    it "assigns the requested vocabulary_collection as @vocabulary_collection" do
      vocabulary_collection = VocabularyCollection.create! valid_attributes
      get :edit, params: { id: vocabulary_collection.to_param }
      expect(assigns(:vocabulary_collection)).to eq(vocabulary_collection)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new VocabularyCollection" do
        expect {
          post :create, params: { vocabulary_collection: valid_attributes }
        }.to change(VocabularyCollection, :count).by(1)
      end

      it "assigns a newly created vocabulary_collection as @vocabulary_collection" do
        post :create, params: { vocabulary_collection: valid_attributes }
        expect(assigns(:vocabulary_collection)).to be_a(VocabularyCollection)
        expect(assigns(:vocabulary_collection)).to be_persisted
      end

      it "redirects to the created vocabulary_collection" do
        post :create, params: { vocabulary_collection: valid_attributes }
        expect(response).to redirect_to(VocabularyCollection.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved vocabulary_collection as @vocabulary_collection" do
        post :create, params: { vocabulary_collection: invalid_attributes }
        expect(assigns(:vocabulary_collection)).to be_a_new(VocabularyCollection)
      end

      it "re-renders the 'new' template" do
        post :create, params: { vocabulary_collection: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { label: 'Updated Label' } }

      it "updates the requested vocabulary_collection" do
        vocabulary_collection = VocabularyCollection.create! valid_attributes
        put :update, params: { id: vocabulary_collection.to_param, vocabulary_collection: new_attributes }
        vocabulary_collection.reload
        expect(vocabulary_collection.label).to eq('Updated Label')
      end

      it "assigns the requested vocabulary_collection as @vocabulary_collection" do
        vocabulary_collection = VocabularyCollection.create! valid_attributes
        put :update, params: { id: vocabulary_collection.to_param, vocabulary_collection: valid_attributes }
        expect(assigns(:vocabulary_collection)).to eq(vocabulary_collection)
      end

      it "redirects to the vocabulary_collection" do
        vocabulary_collection = VocabularyCollection.create! valid_attributes
        put :update, params: { id: vocabulary_collection.to_param, vocabulary_collection: valid_attributes }
        expect(response).to redirect_to(vocabulary_collection)
      end
    end

    context "with invalid params" do
      it "assigns the vocabulary_collection as @vocabulary_collection" do
        vocabulary_collection = VocabularyCollection.create! valid_attributes
        put :update, params: { id: vocabulary_collection.to_param, vocabulary_collection: invalid_attributes }
        expect(assigns(:vocabulary_collection)).to eq(vocabulary_collection)
      end

      it "re-renders the 'edit' template" do
        vocabulary_collection = VocabularyCollection.create! valid_attributes
        put :update, params: { id: vocabulary_collection.to_param, vocabulary_collection: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested vocabulary_collection" do
      vocabulary_collection = VocabularyCollection.create! valid_attributes
      expect {
        delete :destroy, params: { id: vocabulary_collection.to_param }
      }.to change(VocabularyCollection, :count).by(-1)
    end

    it "redirects to the vocabulary_collections list" do
      vocabulary_collection = VocabularyCollection.create! valid_attributes
      delete :destroy, params: { id: vocabulary_collection.to_param }
      expect(response).to redirect_to(vocabulary_collections_url)
    end
  end
end
