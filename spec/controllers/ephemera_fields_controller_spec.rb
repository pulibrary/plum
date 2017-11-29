# frozen_string_literal: true
require 'rails_helper'

RSpec.describe EphemeraFieldsController, type: :controller do
  let(:project) { FactoryGirl.create :ephemera_project }
  let(:vocab) { FactoryGirl.create :vocabulary }
  let(:valid_attributes) { { name: 'EphemeraFolder.language', vocabulary_id: vocab.id } }
  let(:invalid_attributes) { { name: nil, vocabulary_id: nil } }
  let(:user) { FactoryGirl.create(:admin) }

  before do
    sign_in user
  end

  describe "GET #new" do
    it "assigns a new ephemera_field as @ephemera_field" do
      get :new, params: { ephemera_project_id: project.id }
      expect(assigns(:ephemera_field)).to be_a_new(EphemeraField)
    end
  end

  describe "GET #edit" do
    it "assigns the requested ephemera_field as @ephemera_field" do
      ephemera_field = EphemeraField.create! valid_attributes
      get :edit, params: { id: ephemera_field.to_param, ephemera_project_id: project.id }
      expect(assigns(:ephemera_field)).to eq(ephemera_field)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new EphemeraField" do
        expect {
          post :create, params: { ephemera_field: valid_attributes, ephemera_project_id: project.id }
        }.to change(EphemeraField, :count).by(1)
      end

      it "assigns a newly created ephemera_field as @ephemera_field" do
        post :create, params: { ephemera_field: valid_attributes, ephemera_project_id: project.id }
        expect(assigns(:ephemera_field)).to be_a(EphemeraField)
        expect(assigns(:ephemera_field)).to be_persisted
      end

      it "redirects to the created ephemera_field" do
        post :create, params: { ephemera_field: valid_attributes, ephemera_project_id: project.id }
        expect(response).to redirect_to(ephemera_project_url(project))
      end
    end

    context "with invalid params" do
      it "fails" do
        expect {
          post :create, params: { ephemera_field: invalid_attributes, ephemera_project_id: project.id }
        }.not_to change(EphemeraField, :count)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: 'EphemeraFolder.genre', vocabulary: vocab } }

      it "updates the requested ephemera_field" do
        ephemera_field = EphemeraField.create! valid_attributes
        put :update, params: { id: ephemera_field.to_param, ephemera_field: new_attributes, ephemera_project_id: project.id }
        ephemera_field.reload
        expect(ephemera_field.name).to eq('EphemeraFolder.genre')
      end

      it "assigns the requested ephemera_field as @ephemera_field" do
        ephemera_field = EphemeraField.create! valid_attributes
        put :update, params: { id: ephemera_field.to_param, ephemera_field: valid_attributes, ephemera_project_id: project.id }
        expect(assigns(:ephemera_field)).to eq(ephemera_field)
      end

      it "redirects to the ephemera_field" do
        ephemera_field = EphemeraField.create! valid_attributes
        put :update, params: { id: ephemera_field.to_param, ephemera_field: valid_attributes, ephemera_project_id: project.id }
        expect(response).to redirect_to(ephemera_project_url(project))
      end
    end

    context "with invalid params" do
      it "does not change the ephemera_field" do
        ephemera_field = EphemeraField.create! valid_attributes
        expect {
          put :update, params: { id: ephemera_field.to_param, ephemera_field: invalid_attributes, ephemera_project_id: project.id }
        }.not_to change { ephemera_field.updated_at }
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested ephemera_field" do
      ephemera_field = EphemeraField.create! valid_attributes
      expect {
        delete :destroy, params: { id: ephemera_field.to_param, ephemera_project_id: project.id }
      }.to change(EphemeraField, :count).by(-1)
    end

    it "redirects to the ephemera_fields list" do
      ephemera_field = EphemeraField.create! valid_attributes
      delete :destroy, params: { id: ephemera_field.to_param, ephemera_project_id: project.id }
      expect(response).to redirect_to(ephemera_project_url(project))
    end
  end
end
