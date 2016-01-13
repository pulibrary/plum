require 'rails_helper'

RSpec.feature 'Collections', type: :feature do
  describe 'an anonymous user is not allowed to create a collection' do
    scenario 'link to create a collection is not shown' do
      visit root_path
      expect(page).not_to have_link 'Add a Collection'
    end

    scenario 'attempting to create a collection fails' do
      visit collections.new_collection_path
      expect(page).to have_selector 'div.alert', 'You need to sign in or sign up before continuing'
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
      expect(page).to have_selector 'h1', 'Create New Collection'

      fill_in 'collection_title', with: 'Test Collection'
      fill_in 'collection_exhibit_id', with: 'slug1'
      click_button 'Create Collection'
      expect(page).to have_selector 'h1', 'Test Collection'
      expect(page).to have_selector 'li.exhibit_id', 'slug1'
    end
    scenario 'fails to input exhibit ID' do
      pending
      visit root_path
      expect(page).to have_link 'Add a Collection'

      click_link 'Add a Collection'
      expect(page).to have_selector 'h1', 'Create New Collection'

      fill_in 'collection_title', with: 'Test Collection'
      click_button 'Create Collection'
      expect(page).to have_selector ".alert"
    end
  end

  describe 'adding resources to collections' do
    let(:collection1) { FactoryGirl.create(:collection, title: 'Col 1') }
    let(:collection2) { FactoryGirl.create(:collection, title: 'Col 2') }
    let(:resource) { FactoryGirl.create(:scanned_resource) }
    before(:each) do
      sign_in user

      visit edit_polymorphic_path [resource]
      select 'Col 1', from: 'scanned_resource_collection_ids'
      click_button 'Update Scanned resource'
      expect(page).to have_selector 'a.collection-link', 'Col 1'
      expect(page).not_to have_selector 'a.collection-link', 'Col 2'

      visit edit_polymorphic_path [resource]
      select 'Col 2', from: 'scanned_resource_collection_ids'
      click_button 'Update Scanned resource'
      expect(page).not_to have_selector 'a.collection-link', 'Col 1'
      expect(page).to have_selector 'a.collection-link', 'Col 2'
    end
  end
end
