require 'rails_helper'

RSpec.describe EphemeraProjectsController, type: :controller do
  let(:valid_attributes) { { name: "Test Project" } }
  let(:invalid_attributes) { { name: nil } }
  let(:user) { FactoryGirl.create(:admin) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "assigns all ephemera_projects as @ephemera_projects" do
      ephemera_project = EphemeraProject.create! valid_attributes
      get :index, params: {}
      expect(assigns(:ephemera_projects)).to eq([ephemera_project])
    end
  end

  describe "GET #show" do
    it "assigns the requested ephemera_project as @ephemera_project" do
      ephemera_project = EphemeraProject.create! valid_attributes
      get :show, params: { id: ephemera_project.to_param }
      expect(assigns(:ephemera_project)).to eq(ephemera_project)
    end
  end

  describe "GET #new" do
    it "assigns a new ephemera_project as @ephemera_project" do
      get :new, params: {}
      expect(assigns(:ephemera_project)).to be_a_new(EphemeraProject)
    end
  end

  describe "GET #edit" do
    it "assigns the requested ephemera_project as @ephemera_project" do
      ephemera_project = EphemeraProject.create! valid_attributes
      get :edit, params: { id: ephemera_project.to_param }
      expect(assigns(:ephemera_project)).to eq(ephemera_project)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new EphemeraProject" do
        expect {
          post :create, params: { ephemera_project: valid_attributes }
        }.to change(EphemeraProject, :count).by(1)
      end

      it "assigns a newly created ephemera_project as @ephemera_project" do
        post :create, params: { ephemera_project: valid_attributes }
        expect(assigns(:ephemera_project)).to be_a(EphemeraProject)
        expect(assigns(:ephemera_project)).to be_persisted
      end

      it "redirects to the created ephemera_project" do
        post :create, params: { ephemera_project: valid_attributes }
        expect(response).to redirect_to(EphemeraProject.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved ephemera_project as @ephemera_project" do
        post :create, params: { ephemera_project: invalid_attributes }
        expect(assigns(:ephemera_project)).to be_a_new(EphemeraProject)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "Updated Name" } }

      it "updates the requested ephemera_project" do
        ephemera_project = EphemeraProject.create! valid_attributes
        put :update, params: { id: ephemera_project.to_param, ephemera_project: new_attributes }
        ephemera_project.reload
        expect(ephemera_project.name).to eq("Updated Name")
      end

      it "assigns the requested ephemera_project as @ephemera_project" do
        ephemera_project = EphemeraProject.create! valid_attributes
        put :update, params: { id: ephemera_project.to_param, ephemera_project: valid_attributes }
        expect(assigns(:ephemera_project)).to eq(ephemera_project)
      end

      it "redirects to the ephemera_project" do
        ephemera_project = EphemeraProject.create! valid_attributes
        put :update, params: { id: ephemera_project.to_param, ephemera_project: valid_attributes }
        expect(response).to redirect_to(ephemera_project)
      end
    end

    context "with invalid params" do
      it "assigns the ephemera_project as @ephemera_project" do
        ephemera_project = EphemeraProject.create! valid_attributes
        put :update, params: { id: ephemera_project.to_param, ephemera_project: invalid_attributes }
        expect(assigns(:ephemera_project)).to eq(ephemera_project)
      end

      it "re-renders the 'edit' template" do
        ephemera_project = EphemeraProject.create! valid_attributes
        put :update, params: { id: ephemera_project.to_param, ephemera_project: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested ephemera_project" do
      ephemera_project = EphemeraProject.create! valid_attributes
      expect {
        delete :destroy, params: { id: ephemera_project.to_param }
      }.to change(EphemeraProject, :count).by(-1)
    end

    it "redirects to the ephemera_projects list" do
      ephemera_project = EphemeraProject.create! valid_attributes
      delete :destroy, params: { id: ephemera_project.to_param }
      expect(response).to redirect_to(ephemera_projects_url)
    end
  end
end
