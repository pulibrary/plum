require 'rails_helper'

RSpec.feature "ScannedResourcesController", type: :feature do
  let(:user) { FactoryGirl.create(:image_editor) }

  context "an authorized user" do
    before(:each) do
      sign_in user
    end

    scenario "Logged in user can create a new scanned resource" do
      visit new_polymorphic_path [ScannedResource]
      expect(page).to_not have_selector("label.label-warning", text: "Pending")

      fill_in 'scanned_resource_title', with: 'Test Title'
      expect(page).to have_select 'scanned_resource_rights_statement', selected: 'No Known Copyright'
      expect(page).to have_select 'scanned_resource_pdf_type', selected: 'Grayscale PDF'
      click_button 'Create Scanned resource'

      expect(page).to have_selector("h1", text: "Test Title")
      expect(page).to have_selector("span.label-default", text: "Pending")
      expect(page).to have_text("No Known Copyright")
    end
  end

  context "an anonymous user" do
    scenario "Anonymous user can't create a scanned resource" do
      visit new_polymorphic_path [ScannedResource]
      expect(page).to have_selector("div.alert-info", text: "You are not authorized to access this page")
    end
  end
end
