require 'rails_helper'

RSpec.feature "ScannedResourcesController", type: :feature do
  let(:user) { FactoryGirl.create(:image_editor) }

  context "an authorized user" do
    let(:scanned_resource) { FactoryGirl.create(:scanned_resource, title: ["first title", "second title"], user: user) }
    before(:each) do
      sign_in user
      scanned_resource
    end

    scenario "Viewing a scanned resource directly it should display both titles" do
      visit polymorphic_path [scanned_resource]
      expect(page).to have_selector "h1", text: "first title"
      expect(page).to have_selector "h1", text: "second title"
      expect(page).not_to have_selector "h1", text: "first title, second title"
      expect(page).not_to have_selector "a", text: I18n.t('blacklight.back_to_search')
    end

    scenario "Viewing a scanned resource from a search it should include link back to search" do
      visit search_catalog_path q: "title"
      first('.index_title > a').click
      expect(page).to have_selector "a", text: I18n.t('blacklight.back_to_search')
    end
  end
end
