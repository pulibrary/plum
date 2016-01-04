require 'rails_helper'

RSpec.feature "ScannedResourcesController", type: :feature do
  let(:user) { FactoryGirl.create(:image_editor) }

  context "an authorized user" do
    before(:each) do
      sign_in user
    end

    scenario "Logged in user can create a new scanned resource" do
      visit new_polymorphic_path [ScannedResource]
      expect(page).to_not have_selector("label.label-warning", "Pending")

      fill_in 'scanned_resource_title', with: 'Test Title'
      select 'Marquand', from: 'scanned_resource_access_policy'
      select 'Marquand', from: 'scanned_resource_use_and_reproduction'
      click_button 'Create Scanned resource'

      expect(page).to have_selector("h1", "Test Title")
      expect(page).to have_selector("span.label-default", "Pending")
      expect(page).to have_text("Jamie, remind me to give you a lesson in tying knots, sometime")
    end
  end

  context "an anonymous user" do
    scenario "Anonymous user can't create a scanned resource" do
      visit new_polymorphic_path [ScannedResource]
      expect(page).to have_selector("div.alert-info", "You are not authorized to access this page")
    end
  end
end
