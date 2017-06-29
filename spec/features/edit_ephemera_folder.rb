require 'rails_helper'

RSpec.feature 'EphemeraFoldersController', type: :feature, admin_set: true do
  let(:user) { FactoryGirl.create(:admin) }
  let(:box) { FactoryGirl.create(:ephemera_box) }
  let(:folder) { FactoryGirl.create(:ephemera_folder, language: ['Spanish']) }

  before(:each) do
    sign_in user
  end

  scenario 'creating a new folder and then creating another' do
    visit "/concern/parent/#{box.id}/ephemera_folders/new?create_another=#{folder.id}"
    expect(find_field('Barcode').value).to eq(nil)
    expect(find_field('Folder number').value).to eq(nil)
    expect(find_field('Title').value).to have_content('Example Folder')
    expect(find_field('Language').value).to have_content('Spanish')
  end

  scenario 'show page links to the contextual edit form' do
    visit hyrax_parent_ephemera_folder_path(box.id, folder.id)
    expect(page).to have_link('Edit This Ephemera Folder', href: "/concern/parent/#{box.id}/ephemera_folders/#{folder.id}/edit?locale=en")
  end
end
