require 'rails_helper'

RSpec.feature 'EphemeraFoldersController', type: :feature, admin_set: true do
  let(:user) { FactoryGirl.create(:admin) }
  let(:box) { FactoryGirl.create(:ephemera_box) }
  let(:collection) { FactoryGirl.create(:collection) }

  before(:each) do
    sign_in user
    collection
  end

  scenario 'creating a new folder in a collection' do
    visit "/concern/parent/#{box.id}/ephemera_folders/new"
    fill_in 'Barcode', with: '00000000000000'
    fill_in 'Folder number', with: '1'
    fill_in 'Title', with: 'Test Title'
    fill_in 'Language', with: 'English'
    fill_in 'Genre', with: 'Bookmarks'
    fill_in 'Width', with: '50'
    fill_in 'Height', with: '50'
    fill_in 'Page count', with: '50'
    select collection.title.first, from: 'Member of collection ids'
    click_button 'Save'
    expect(page).to have_content "Test Title"
  end
end
