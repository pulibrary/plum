require 'rails_helper'

RSpec.feature "CatalogController", type: :feature do
  describe "admin user" do
    let(:user) { FactoryGirl.create(:admin) }
    let(:scanned_resource) { FactoryGirl.create(:scanned_resource, user: user) }

    before(:each) do
      sign_in user
      scanned_resource.update_index
    end

    scenario "Admin users see a state facet" do
      visit catalog_index_path q: ""
      expect(page).to have_text "Test title"
      expect(page).to have_selector "div.blacklight-state_sim", text: "State"
    end
  end

  describe "image_editor user" do
    let(:user) { FactoryGirl.create(:image_editor) }
    let(:scanned_resource) { FactoryGirl.create(:scanned_resource, user: user) }

    before(:each) do
      sign_in user
      scanned_resource.update_index
    end

    scenario "CurationConcerns creators see a state facet" do
      visit catalog_index_path q: ""
      expect(page).to have_text "Test title"
      expect(page).to have_selector "div.blacklight-state_sim", text: "State"
    end
  end

  describe "anonymous user" do
    let(:user) { FactoryGirl.create(:image_editor) }
    let(:scanned_resource) { FactoryGirl.create(:scanned_resource, user: user) }

    before(:each) do
      scanned_resource.update_index
    end

    scenario "Anonymous users do not see a state facet" do
      visit catalog_index_path q: ""
      expect(page).to have_text "Test title"
      expect(page).not_to have_selector "div.blacklight-state_sim", text: "State"
    end
  end
end
