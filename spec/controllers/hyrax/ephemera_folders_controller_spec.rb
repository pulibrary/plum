# Generated via
#  `rails generate hyrax:work EphemeraFolder`
require 'rails_helper'

RSpec.describe Hyrax::EphemeraFoldersController, admin_set: true do
  let(:folder) { FactoryGirl.build(:ephemera_folder) }
  let(:box) { FactoryGirl.create(:ephemera_box) }
  let(:box2) { FactoryGirl.create(:ephemera_box, title: ['Box 2']) }
  let(:user) { FactoryGirl.create(:admin) }
  let(:attributes) do
    {
      title: "Test",
      barcode: folder.barcode.first
    }
  end
  describe "#create" do
    it "creates it as a sub-resource of a box" do
      sign_in user
      post :create, params: { ephemera_folder: attributes.merge(box_id: box.id) }

      expect(response).to be_redirect
      id = response.headers["Location"].match(/.*\/(.*)\?/)[1]
      expect(ActiveFedora::Base.find(id).member_of_collections).to eq [box]
    end
  end

  describe "#update" do
    let(:updated) { { title: 'New Title', barcode: folder.barcode.first, box_id: box2.id } }
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
end
