require 'rails_helper'

RSpec.describe VocabulariesController, type: :controller do
  let(:user) { FactoryGirl.create(:admin) }

  before do
    sign_in user
  end

  # This should return the minimal set of attributes required to create a valid
  # Vocabulary. As you add validations to Vocabulary, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { label: 'Test Vocab' } }

  let(:invalid_attributes) { { label: nil } }

  describe "GET #index" do
    it "assigns all vocabularies as @vocabularies" do
      vocabulary = Vocabulary.create! valid_attributes
      get :index, params: {}
      expect(assigns(:vocabularies)).to eq([vocabulary])
    end
  end

  describe "GET #show" do
    it "assigns the requested vocabulary as @vocabulary" do
      vocabulary = Vocabulary.create! valid_attributes
      get :show, params: { id: vocabulary.to_param }
      expect(assigns(:vocabulary)).to eq(vocabulary)
    end
  end

  describe "GET #new" do
    it "assigns a new vocabulary as @vocabulary" do
      get :new, params: {}
      expect(assigns(:vocabulary)).to be_a_new(Vocabulary)
    end
  end

  describe "GET #edit" do
    it "assigns the requested vocabulary as @vocabulary" do
      vocabulary = Vocabulary.create! valid_attributes
      get :edit, params: { id: vocabulary.to_param }
      expect(assigns(:vocabulary)).to eq(vocabulary)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Vocabulary" do
        expect {
          post :create, params: { vocabulary: valid_attributes }
        }.to change(Vocabulary, :count).by(1)
      end

      it "assigns a newly created vocabulary as @vocabulary" do
        post :create, params: { vocabulary: valid_attributes }
        expect(assigns(:vocabulary)).to be_a(Vocabulary)
        expect(assigns(:vocabulary)).to be_persisted
      end

      it "redirects to the created vocabulary" do
        post :create, params: { vocabulary: valid_attributes }
        expect(response).to redirect_to(Vocabulary.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved vocabulary as @vocabulary" do
        post :create, params: { vocabulary: invalid_attributes }
        expect(assigns(:vocabulary)).to be_a_new(Vocabulary)
      end

      it "re-renders the 'new' template" do
        post :create, params: { vocabulary: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { label: 'Updated Label' } }

      it "updates the requested vocabulary" do
        vocabulary = Vocabulary.create! valid_attributes
        put :update, params: { id: vocabulary.to_param, vocabulary: new_attributes }
        vocabulary.reload
        expect(assigns(:vocabulary).label).to eq('Updated Label')
      end

      it "assigns the requested vocabulary as @vocabulary" do
        vocabulary = Vocabulary.create! valid_attributes
        put :update, params: { id: vocabulary.to_param, vocabulary: valid_attributes }
        expect(assigns(:vocabulary)).to eq(vocabulary)
      end

      it "redirects to the vocabulary" do
        vocabulary = Vocabulary.create! valid_attributes
        put :update, params: { id: vocabulary.to_param, vocabulary: valid_attributes }
        expect(response).to redirect_to(vocabulary)
      end
    end

    context "with invalid params" do
      it "assigns the vocabulary as @vocabulary" do
        vocabulary = Vocabulary.create! valid_attributes
        put :update, params: { id: vocabulary.to_param, vocabulary: invalid_attributes }
        expect(assigns(:vocabulary)).to eq(vocabulary)
      end

      it "re-renders the 'edit' template" do
        vocabulary = Vocabulary.create! valid_attributes
        put :update, params: { id: vocabulary.to_param, vocabulary: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested vocabulary" do
      vocabulary = Vocabulary.create! valid_attributes
      expect {
        delete :destroy, params: { id: vocabulary.to_param }
      }.to change(Vocabulary, :count).by(-1)
    end

    it "redirects to the vocabularies list" do
      vocabulary = Vocabulary.create! valid_attributes
      delete :destroy, params: { id: vocabulary.to_param }
      expect(response).to redirect_to(vocabularies_url)
    end
  end
end
