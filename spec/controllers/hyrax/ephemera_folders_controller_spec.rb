# Generated via
#  `rails generate hyrax:work EphemeraFolder`
require 'rails_helper'

RSpec.describe Hyrax::EphemeraFoldersController, admin_set: true do
  let(:folder) { FactoryGirl.build(:ephemera_folder) }
  let(:box) { FactoryGirl.create(:ephemera_box) }
  let(:box2) { FactoryGirl.create(:ephemera_box, title: ['Box 2']) }
  let(:user) { FactoryGirl.create(:admin) }
  let(:barcode0) { '00000000000000' }
  let(:attributes) do
    {
      title: "Test",
      barcode: folder.barcode.first
    }
  end
  describe "#create" do
    before do
      sign_in user
    end

    it "creates it as a sub-resource of a box" do
      post :create, params: { ephemera_folder: attributes.merge(box_id: box.id, barcode: folder.barcode.first, rights_statement: "http://rightsstatements.org/vocab/NKC/1.0/") }

      expect(response).to be_redirect
      id = response.headers["Location"].match(/.*\/(.*)/)[1]
      expect(ActiveFedora::Base.find(id).member_of_collections).to eq [box]
    end

    it "uses the newly created record as a template when 'save and create another' is used" do
      post :create, params: { ephemera_folder: attributes.merge(box_id: box.id, barcode: folder.barcode.first, rights_statement: "http://rightsstatements.org/vocab/NKC/1.0/"), save_and_create_another: true, parent_id: box.id }
      expect(response).to be_redirect
      expect(response.location).to include('create_another=')
    end
  end

  describe "#update" do
    let(:updated) { { title: 'New Title', barcode: barcode0, box_id: box2.id } }
    let(:reloaded) { folder.reload }

    before do
      folder.save
    end

    it "updates the metadata" do
      sign_in user
      post :update, params: { id: folder.id, ephemera_folder: updated }
      expect(reloaded.title).to eq(['New Title'])
      expect(reloaded.box).to eq(box2)
    end
  end

  describe "#new" do
    context "when created with a template" do
      it "uses the template's params to initialize" do
        sign_in user
        template = FactoryGirl.create(:template, template_class: "EphemeraFolder", params: { title: ["Test Title"] })

        get :new, params: { parent_id: box.id, template_id: template.id }

        expect(assigns[:curation_concern].title).to eq ["Test Title"]
      end
    end
  end

  describe "#file_manager" do
    before do
      folder.save
    end
    context "when not signed in" do
      it "does not allow them to view it" do
        get :file_manager, params: { id: folder.id }
        expect(response).not_to be_success
      end
    end
    context "when logged in as an admin" do
      render_views
      let(:user) { FactoryGirl.create(:admin) }
      it "lets them see it" do
        sign_in user
        get :file_manager, params: { id: folder.id }
        expect(response).to be_success
      end
    end
  end

  describe "#manifest" do
    let(:solr) { ActiveFedora.solr.conn }
    let(:user) { FactoryGirl.create(:admin) }
    context "when requesting JSON" do
      render_views
      before do
        sign_in user
      end
      it "builds a manifest" do
        resource = FactoryGirl.create(:ephemera_folder)
        resource_2 = FactoryGirl.create(:ephemera_folder)
        allow(resource).to receive(:id).and_return("test")
        allow(resource_2).to receive(:id).and_return("test2")
        solr.add resource.to_solr
        solr.add resource_2.to_solr
        solr.commit
        expect(EphemeraFolder).not_to receive(:find)

        get :manifest, params: { id: "test2", format: :json }

        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['@id']).to eq "http://plum.com/concern/ephemera_folders/test2/manifest"
        expect(response_json["service"]).to eq nil
      end
    end
  end
end
