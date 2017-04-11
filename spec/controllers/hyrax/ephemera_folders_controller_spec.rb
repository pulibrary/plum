# Generated via
#  `rails generate hyrax:work EphemeraFolder`
require 'rails_helper'

RSpec.describe Hyrax::EphemeraFoldersController, admin_set: true do
  let(:folder) { FactoryGirl.build(:ephemera_folder) }
  let(:box) { FactoryGirl.create(:ephemera_box) }
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
end
