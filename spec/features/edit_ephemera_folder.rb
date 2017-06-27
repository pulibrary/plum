require 'rails_helper'

RSpec.feature 'EphemeraFoldersController', type: :feature, admin_set: true do
  let(:user) { FactoryGirl.create(:ephemera_editor) }
  let(:box) { FactoryGirl.create(:ephemera_box) }
  let(:folder) { FactoryGirl.create(:ephemera_folder, language: ['Spanish']) }

  before(:each) do
    sign_in user
  end

  scenario 'creating a new folder and then creating another' do
    puts "/concern/parent/#{box.id}/ephemera_folders/new?create_another=#{folder.id}"
    visit "/concern/parent/#{box.id}/ephemera_folders/new?create_another=#{folder.id}"
    expect(find_field('Barcode').value).to eq(nil)
    expect(find_field('Folder number').value).to eq(nil)
    expect(find_field('Title').value).to have_content('Example Folder')
    expect(find_field('Language').value).to have_content('Spanish')
  end
end
