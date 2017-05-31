require 'rails_helper'

RSpec.feature 'Collections', type: :feature, admin_set: true do
  describe 'an anonymous user is not allowed to create a collection' do
    scenario 'link to create a collection is not shown' do
      visit root_path
      expect(page).not_to have_link 'Add a Collection'
    end

    scenario 'attempting to create a collection fails' do
      visit new_collection_path
      expect(page).to have_selector 'div.alert', text: 'You are not authorized to access this page'
    end
  end

  describe 'a logged in user is allowed to create a collection' do
    let(:user) { FactoryGirl.create(:image_editor) }

    before(:each) do
      sign_in user
    end

    scenario 'is allowed to create collections' do
      visit root_path
      expect(page).to have_link 'Add a Collection'

      click_link 'Add a Collection'
      expect(page).to have_selector 'h1', text: 'Create New Collection'

      fill_in 'collection_title', with: 'Test Collection'
      fill_in 'collection_exhibit_id', with: 'slug1'
      click_button 'Create Collection'
      expect(page).to have_selector 'h1', text: 'Test Collection'
      expect(page).to have_selector 'li.exhibit_id', text: 'slug1'
    end
    scenario 'is edited' do
      s = FactoryGirl.create(:scanned_resource_in_collection, user: user)
      c = s.member_of_collections.first

      visit collection_path(c)
      within('.actions-controls-collections') do
        click_link 'Edit'
      end

      expect(page).to have_field 'collection_title', with: c.title.first
      fill_in 'collection_title', with: "Alfafa"
      within(".primary-actions") do
        click_button "Update Collection"
      end
      expect(page).to have_selector "h1", text: "Alfafa"
    end
    scenario 'fails to input exhibit ID' do
      visit root_path
      expect(page).to have_link 'Add a Collection'

      click_link 'Add a Collection'
      expect(page).to have_selector 'h1', text: 'Create New Collection'

      fill_in 'collection_title', with: 'Test Collection'
      click_button 'Create Collection'
      expect(page).to have_selector ".alert"
    end
  end

  describe 'adding resources to collections', vcr: { cassette_name: 'locations', allow_playback_repeats: true } do
    let(:collection1) { FactoryGirl.create(:collection, title: ['Col 1']) }
    let(:collection2) { FactoryGirl.create(:collection, title: ['Col 2']) }
    let(:resource) { FactoryGirl.create(:scanned_resource) }
    let(:user) { FactoryGirl.create(:image_editor) }
    before(:each) do
      collection1
      collection2
      resource
      sign_in user
    end
    it "works" do
      visit edit_polymorphic_path [resource]
      select 'Col 1', from: 'scanned_resource[member_of_collection_ids][]'
      click_button 'Save'
      expect(page).to have_selector 'a.collection-link', text: 'Col 1'
      expect(page).not_to have_selector 'a.collection-link', text: 'Col 2'

      visit edit_polymorphic_path [resource]
      select 'Col 2', from: 'scanned_resource[member_of_collection_ids][]'
      unselect 'Col 1', from: 'scanned_resource[member_of_collection_ids][]'
      click_button 'Save'
      expect(page).not_to have_selector 'a.collection-link', text: 'Col 1'
      expect(page).to have_selector 'a.collection-link', text: 'Col 2'

      visit edit_polymorphic_path [resource]
      unselect 'Col 2', from: 'scanned_resource[member_of_collection_ids][]'
      click_button 'Save'
      expect(page).not_to have_selector 'a.collection-link', text: 'Col 1'
      expect(page).not_to have_selector 'a.collection-link', text: 'Col 2'
    end
  end
end
