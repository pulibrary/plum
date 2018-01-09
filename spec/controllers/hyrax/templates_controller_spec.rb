# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::TemplatesController do
  let(:user) { FactoryGirl.create(:ephemera_editor) }
  before do
    sign_in user if user
  end
  describe "#index" do
    context "when not authenticated" do
      let(:user) {}
      it "is unauthorized" do
        get :index
        expect(response).to be_redirect
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end
    end
    context "when authenticated" do
      it "sets @templates to all templates" do
        template = FactoryGirl.create(:template)

        get :index

        expect(assigns[:templates]).to eq [template]
      end
    end
  end

  describe "#new" do
    context "when not authenticated" do
      let(:user) {}
      it "is unauthorized" do
        get :new
        expect(response).to be_redirect
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end
    end
    context "when authenticated" do
      render_views
      before do
        allow_any_instance_of(HoldingLocationAuthority).to receive(:all).and_return([])
      end
      it "sets @form" do
        get :new, params: { class_type: "ScannedResource" }
        expect(assigns[:form]).not_to be_nil
      end
    end
  end

  describe "#edit" do
    context "when not authenticated" do
      let(:user) {}
      it "is unauthorized" do
        get :edit, params: { id: "test" }
        expect(response).to be_redirect
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end
    end
    context "when authenticated" do
      it "sets @form" do
        template = FactoryGirl.create(:template)
        get :edit, params: { id: template.id, class_type: "ScannedResource" }
        expect(assigns[:form]).not_to be_nil
      end
    end
  end

  describe "#create" do
    context "when not authenticated" do
      let(:user) {}
      it "is unauthorized" do
        put :create, params: { class_type: "ScannedResource", template: { template_label: "Testing", title: ["First"] } }
        expect(response).to be_redirect
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end
    end
    context "when authorized" do
      it "creates a template" do
        post :create, params: { class_type: "ScannedResource", template: { template_label: "Testing", title: ["First"] } }

        template = Template.last
        expect(template.template_class).to eq "ScannedResource"
        expect(template.template_label).to eq "Testing"
        expect(template.params[:title]).to eq ["First"]
        expect(response).to redirect_to "/templates?locale=en"
      end
      context "when creating an EphemeraFolder" do
        it "redirects to the box the folder is a part of" do
          box = FactoryGirl.create(:ephemera_box)
          post :create, params: { class_type: "EphemeraFolder", parent_id: box.id, template: { box_id: box.id, template_label: "Testing", title: ["First"] } }
          expect(response).to redirect_to "/concern/ephemera_boxes/#{box.id}?locale=en"
        end
      end
    end
  end

  describe "#destroy" do
    context "when not authenticated" do
      let(:user) {}
      it "is unauthorized" do
        delete :destroy, params: { id: "1" }

        expect(response).to be_redirect
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end
    end
    context "when authorized" do
      it "deletes the template" do
        template = FactoryGirl.create(:template)
        request.env["HTTP_REFERER"] = "http://go.back"

        delete :destroy, params: { id: template.id }

        expect(response).to redirect_to "http://go.back"
        expect { Template.find(template.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#update" do
    context "when not authenticated" do
      let(:user) {}
      it "is unauthorized" do
        patch :update, params: { id: "1" }

        expect(response).to be_redirect
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end
    end
    context "when authorized" do
      it "updates the template" do
        template = FactoryGirl.create(:template, template_class: "ScannedResource")

        post :update, params: { id: template.id, class_type: "ScannedResource", template: { template_label: "testing", title: ["Test"] } }

        template.reload
        expect(template.template_label).to eq "testing"
        expect(template.params[:title]).to eq ["Test"]
      end
    end
  end
end
