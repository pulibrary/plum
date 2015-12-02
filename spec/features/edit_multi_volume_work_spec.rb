require 'rails_helper'

RSpec.feature "MultiVolumeWorksController", type: :feature do
  let(:user) { FactoryGirl.create(:curation_concern_creator) }
  let(:multi_volume_work) { FactoryGirl.create(:multi_volume_work, user: user) }

  before(:each) do
    sign_in user
  end

  scenario "Logged in user can follow link to edit multi-volume work" do
    visit polymorphic_path [:curation_concerns, multi_volume_work]
    click_link 'Edit This Multi Volume Work'
    expect(page).to have_text('Manage Your Work')
  end

  scenario "User can edit a multi-volume work", vcr: { cassette_name: "ezid" } do
    Ezid::Client.configure do |conf| conf.logger = Logger.new(File::NULL); end

    visit edit_polymorphic_path [:curation_concerns, multi_volume_work]
    fill_in 'multi_volume_work_source_metadata_identifier', with: '1234568'
    fill_in 'multi_volume_work_portion_note', with: 'new portion note'
    fill_in 'multi_volume_work_description', with: 'new description'
    fill_in 'multi_volume_work_workflow_note', with: 'New note'
    choose 'Complete'

    click_button 'Update Multi volume work'
    expect(page).to have_text("Test title (Multi Volume Work)")
    expect(page).to have_text("New note")
    expect(page).to have_selector("span.label-success", "Complete")
  end

  scenario "User can create a new scanned resource attached to the multi-volume work" do
    visit polymorphic_path [:curation_concerns, multi_volume_work]
    expect(page).to have_text('This Multi Volume Work has no scanned resources associated with it')

    click_link 'Attach a Scanned Resource'
    fill_in 'scanned_resource_title', with: 'Volume 1'
    select 'Marquand', from: 'scanned_resource_access_policy'
    select 'Marquand', from: 'scanned_resource_use_and_reproduction'
    click_button 'Create Scanned resource'

    visit polymorphic_path [:curation_concerns, multi_volume_work]
    expect(page).to have_link('Volume 1', count: 1)
  end
end
