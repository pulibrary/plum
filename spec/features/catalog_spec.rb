require 'rails_helper'

RSpec.feature "CatalogController", type: :feature do
  describe "admin user" do
    let(:user) { FactoryGirl.create(:admin) }
    let(:scanned_resource) { FactoryGirl.create(:complete_scanned_resource_in_collection, user: user, language: ['English']) }

    before(:each) do
      sign_in user
      scanned_resource.update_index
    end

    scenario "Admin users see collection, language, and state facets" do
      visit search_catalog_path q: ""
      expect(page).to have_text "Test title"
      expect(page).to have_selector "div.blacklight-member_of_collections_ssim", text: "Collection"
      expect(page).to have_selector "div.blacklight-language_sim", text: "Language"
      expect(page).to have_selector "div.blacklight-workflow_state_name_ssim", text: "State"
    end
  end

  describe "image_editor user" do
    let(:user) { FactoryGirl.create(:image_editor) }
    let(:scanned_resource) { FactoryGirl.create(:complete_scanned_resource, user: user) }

    before(:each) do
      sign_in user
      scanned_resource.update_index
    end

    scenario "Hyrax creators see a state facet" do
      visit search_catalog_path q: ""
      expect(page).to have_text "Test title"
      expect(page).to have_selector "div.blacklight-workflow_state_name_ssim", text: "State"
    end
  end

  describe "anonymous user" do
    let(:user) { FactoryGirl.create(:image_editor) }
    let(:scanned_resource) { FactoryGirl.create(:complete_scanned_resource, user: user) }

    before(:each) do
      scanned_resource.update_index
    end

    scenario "Anonymous users do not see a state facet" do
      visit search_catalog_path q: ""
      expect(page).to have_text "Test title"
      expect(page).not_to have_selector "div.blacklight-workflow_state_name_ssim", text: "State"
    end
  end

  describe "language and date formatting" do
    let(:user) { FactoryGirl.create(:admin) }
    let(:scanned_resource) { FactoryGirl.create(:complete_scanned_resource, user: user, language: ['deu'], date_created: ['1941-10-23T00:00:00Z']) }

    before(:each) do
      sign_in user
      scanned_resource.update_index
    end

    scenario "formatted versions are displayed" do
      visit search_catalog_path q: ""
      expect(page).to have_text 'German'
      expect(page).to_not have_text 'deu'
      expect(page).to have_text '10/23/1941'
      expect(page).to_not have_text '1941-10-23'
    end
  end
end
