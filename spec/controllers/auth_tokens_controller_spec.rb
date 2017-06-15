require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe AuthTokensController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # AuthToken. As you add validations to AuthToken, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { groups: ["admin"] }
  }
  let(:user) { FactoryGirl.create(:admin) }
  before do
    sign_in user
  end

  describe "GET #index" do
    it "assigns all auth_tokens as @auth_tokens" do
      auth_token = AuthToken.create! valid_attributes
      get :index, params: {}
      expect(assigns(:auth_tokens)).to eq([auth_token])
    end
  end

  describe "GET #show" do
    it "assigns the requested auth_token as @auth_token" do
      auth_token = AuthToken.create! valid_attributes
      get :show, params: { id: auth_token.to_param }
      expect(assigns(:auth_token)).to eq(auth_token)
    end
  end

  describe "GET #new" do
    it "assigns a new auth_token as @auth_token" do
      get :new, params: {}
      expect(assigns(:auth_token)).to be_a_new(AuthToken)
    end
  end

  describe "GET #edit" do
    it "assigns the requested auth_token as @auth_token" do
      auth_token = AuthToken.create! valid_attributes
      get :edit, params: { id: auth_token.to_param }
      expect(assigns(:auth_token)).to eq(auth_token)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new AuthToken" do
        expect {
          post :create, params: { auth_token: valid_attributes }
        }.to change(AuthToken, :count).by(1)
      end

      it "assigns a newly created auth_token as @auth_token" do
        post :create, params: { auth_token: valid_attributes }
        expect(assigns(:auth_token)).to be_a(AuthToken)
        expect(assigns(:auth_token)).to be_persisted
      end

      it "redirects to the created auth_token" do
        post :create, params: { auth_token: valid_attributes }
        expect(response).to redirect_to(AuthToken.last)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { groups: ['ephemera_editor'] } }

      it "updates the requested vocabulary_term" do
        auth_token = AuthToken.create! valid_attributes
        put :update, params: { id: auth_token.to_param, auth_token: new_attributes }
        auth_token.reload
        expect(auth_token.groups).to eq(['ephemera_editor'])
      end

      it "assigns the requested auth_token as @auth_token" do
        auth_token = AuthToken.create! valid_attributes
        put :update, params: { id: auth_token.to_param, auth_token: valid_attributes }
        expect(assigns(:auth_token)).to eq(auth_token)
      end

      it "redirects to the auth_token" do
        auth_token = AuthToken.create! valid_attributes
        put :update, params: { id: auth_token.to_param, auth_token: valid_attributes }
        expect(response).to redirect_to(auth_token)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested auth_token" do
      auth_token = AuthToken.create! valid_attributes
      expect {
        delete :destroy, params: { id: auth_token.to_param }
      }.to change(AuthToken, :count).by(-1)
    end

    it "redirects to the auth_tokens list" do
      auth_token = AuthToken.create! valid_attributes
      delete :destroy, params: { id: auth_token.to_param }
      expect(response).to redirect_to(auth_tokens_url)
    end
  end
end