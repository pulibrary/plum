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

  describe "searching by identifiers and other metadata" do
    let(:user) { FactoryGirl.create(:admin) }
    let(:scanned_resource) { FactoryGirl.create(:complete_scanned_resource, user: user, title: ['This is a persimmon title'], creator: ['Smithee, Al'], replaces: ['pudl8675/309'], identifier: ['ark:/99999/p12345678'], call_number: ['998y']) }

    before(:each) do
      scanned_resource.update_index
    end

    it "finds the resource by title" do
      visit search_catalog_path q: 'persimmon'
      expect(page).to have_text 'This is a persimmon title'
    end

    it "finds the resource by creator" do
      visit search_catalog_path q: 'Smithee'
      expect(page).to have_text 'This is a persimmon title'
    end

    it "finds the resource by replaces" do
      visit search_catalog_path q: 'pudl8675/309'
      expect(page).to have_text 'This is a persimmon title'
    end

    it "finds the resource by partial replaces" do
      visit search_catalog_path q: '309'
      expect(page).to have_text 'This is a persimmon title'
    end

    it "finds the resource by ark" do
      visit search_catalog_path q: 'ark:/9999/p12345678'
      expect(page).to have_text 'This is a persimmon title'
    end

    it "finds the resource by partial ark" do
      visit search_catalog_path q: 'p12345678'
      expect(page).to have_text 'This is a persimmon title'
    end

    it "finds the resource by call number" do
      visit search_catalog_path q: '998y'
      expect(page).to have_text 'This is a persimmon title'
    end
  end
end
