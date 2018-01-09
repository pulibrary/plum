# frozen_string_literal: true
require 'rails_helper'

RSpec.describe VocabularyTermsController, type: :controller do
  let(:vocabulary) { FactoryGirl.create(:vocabulary) }
  let(:user) { FactoryGirl.create(:admin) }

  before do
    sign_in user
  end

  # This should return the minimal set of attributes required to create a valid
  # VocabularyTerm. As you add validations to VocabularyTerm, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { label: 'Term 1', uri: 'http://example.org/term/1', vocabulary_id: vocabulary.id } }

  let(:invalid_attributes) { { label: nil, vocabulary_id: nil } }

  describe "GET #index" do
    it "assigns all vocabulary_terms as @vocabulary_terms" do
      vocabulary_term = VocabularyTerm.create! valid_attributes
      get :index, params: {}
      expect(assigns(:vocabulary_terms)).to eq([vocabulary_term])
    end
  end

  describe "GET #show" do
    it "assigns the requested vocabulary_term as @vocabulary_term" do
      vocabulary_term = VocabularyTerm.create! valid_attributes
      get :show, params: { id: vocabulary_term.to_param }
      expect(assigns(:vocabulary_term)).to eq(vocabulary_term)
    end

    it "serves JSON-LD" do
      vocabulary_term = VocabularyTerm.create! valid_attributes
      get :show, params: { id: vocabulary_term.to_param, format: :jsonld }

      json = JSON.parse(response.body)
      expect(json['@id']).to eq(vocabulary_term_url(vocabulary_term, locale: nil))
      expect(json['@type']).to eq('skos:Concept')
      expect(json['pref_label']).to eq(vocabulary_term.label)
    end

    it "serves Turtle", vcr: { cassette_name: 'context.json' } do
      vocabulary_term = VocabularyTerm.create! valid_attributes
      get :show, params: { id: vocabulary_term.to_param, format: :ttl }

      expect(response.body).to include "<http://www.w3.org/2004/02/skos/core#prefLabel> \"#{vocabulary_term.label}\""
    end

    it "serves N-Triples", vcr: { cassette_name: 'context.json' } do
      vocabulary_term = VocabularyTerm.create! valid_attributes
      get :show, params: { id: vocabulary_term.to_param, format: :nt }

      expect(response.body).to include "<http://www.w3.org/2004/02/skos/core#prefLabel> \"#{vocabulary_term.label}\""
    end
  end

  describe "GET #new" do
    it "assigns a new vocabulary_term as @vocabulary_term" do
      get :new, params: {}
      expect(assigns(:vocabulary_term)).to be_a_new(VocabularyTerm)
    end
  end

  describe "GET #edit" do
    it "assigns the requested vocabulary_term as @vocabulary_term" do
      vocabulary_term = VocabularyTerm.create! valid_attributes
      get :edit, params: { id: vocabulary_term.to_param }
      expect(assigns(:vocabulary_term)).to eq(vocabulary_term)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new VocabularyTerm" do
        expect {
          post :create, params: { vocabulary_term: valid_attributes }
        }.to change(VocabularyTerm, :count).by(1)
      end

      it "assigns a newly created vocabulary_term as @vocabulary_term" do
        post :create, params: { vocabulary_term: valid_attributes }
        expect(assigns(:vocabulary_term)).to be_a(VocabularyTerm)
        expect(assigns(:vocabulary_term)).to be_persisted
      end

      it "redirects to the created vocabulary_term" do
        post :create, params: { vocabulary_term: valid_attributes }
        expect(response).to redirect_to(VocabularyTerm.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved vocabulary_term as @vocabulary_term" do
        post :create, params: { vocabulary_term: invalid_attributes }
        expect(assigns(:vocabulary_term)).to be_a_new(VocabularyTerm)
      end

      it "re-renders the 'new' template" do
        post :create, params: { vocabulary_term: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { label: 'Updated Label' } }

      it "updates the requested vocabulary_term" do
        vocabulary_term = VocabularyTerm.create! valid_attributes
        put :update, params: { id: vocabulary_term.to_param, vocabulary_term: new_attributes }
        vocabulary_term.reload
        expect(vocabulary_term.label).to eq('Updated Label')
      end

      it "assigns the requested vocabulary_term as @vocabulary_term" do
        vocabulary_term = VocabularyTerm.create! valid_attributes
        put :update, params: { id: vocabulary_term.to_param, vocabulary_term: valid_attributes }
        expect(assigns(:vocabulary_term)).to eq(vocabulary_term)
      end

      it "redirects to the vocabulary_term" do
        vocabulary_term = VocabularyTerm.create! valid_attributes
        put :update, params: { id: vocabulary_term.to_param, vocabulary_term: valid_attributes }
        expect(response).to redirect_to(vocabulary_term)
      end
    end

    context "with invalid params" do
      it "assigns the vocabulary_term as @vocabulary_term" do
        vocabulary_term = VocabularyTerm.create! valid_attributes
        put :update, params: { id: vocabulary_term.to_param, vocabulary_term: invalid_attributes }
        expect(assigns(:vocabulary_term)).to eq(vocabulary_term)
      end

      it "re-renders the 'edit' template" do
        vocabulary_term = VocabularyTerm.create! valid_attributes
        put :update, params: { id: vocabulary_term.to_param, vocabulary_term: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested vocabulary_term" do
      vocabulary_term = VocabularyTerm.create! valid_attributes
      expect {
        delete :destroy, params: { id: vocabulary_term.to_param }
      }.to change(VocabularyTerm, :count).by(-1)
    end

    it "redirects to the vocabulary_terms list" do
      vocabulary_term = VocabularyTerm.create! valid_attributes
      delete :destroy, params: { id: vocabulary_term.to_param }
      expect(response).to redirect_to(vocabulary_terms_url)
    end
  end
end
