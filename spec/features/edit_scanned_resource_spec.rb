require 'rails_helper'

RSpec.feature "ScannedResourcesController", type: :feature do
  let(:user) { FactoryGirl.create(:scanned_resource_creator) }
  let(:scanned_resource) { FactoryGirl.create(:scanned_resource, user: user) }

  before(:each) do
    sign_in user
  end

  scenario "Logged in user can follow link to edit scanned resource" do
    visit polymorphic_path [:curation_concerns, scanned_resource]
    click_link 'Edit This Scanned Resource'
    expect(page).to have_text('Manage Your Work')
  end

  scenario "User can edit a scanned resource" do
    visit edit_polymorphic_path [:curation_concerns, scanned_resource]
    fill_in 'scanned_resource_source_metadata_identifier', with: '1234568'
    fill_in 'scanned_resource_portion_note', with: 'new portion note'
    fill_in 'scanned_resource_description', with: 'new description'
    click_button 'Update Scanned resource'
    expect(page).to have_text("Test title (Scanned Resource)")
  end

  scenario "User can add a new file" do
    allow(CharacterizeJob).to receive(:perform_later).once
    allow_any_instance_of(FileSet).to receive(:warn) # suppress virus warning messages

    visit polymorphic_path [:curation_concerns, scanned_resource]
    click_link 'Attach a File'

    within("form.new_file_set") do
      fill_in("Title", with: 'image.png')
      attach_file("Upload a file", File.join(Rails.root, 'spec/fixtures/files/image.png'))
      click_on("Attach to Scanned Resource")
    end

    within '.related_files' do
      expect(page).to have_link "image.png"
    end
  end
end
