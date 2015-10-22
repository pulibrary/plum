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

  scenario "User can edit a multi-volume work" do
    visit edit_polymorphic_path [:curation_concerns, multi_volume_work]
    fill_in 'multi_volume_work_source_metadata_identifier', with: '1234568'
    fill_in 'multi_volume_work_portion_note', with: 'new portion note'
    fill_in 'multi_volume_work_description', with: 'new description'
    click_button 'Update Multi Volume Work'
    expect(page).to have_text("Test title (Multi Volume Work)")
  end
end
