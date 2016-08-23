require 'rails_helper'

RSpec.feature "ScannedResourcesController", type: :feature do
  let(:user) { FactoryGirl.create(:image_editor) }
  let(:scanned_resource) { FactoryGirl.create(:scanned_resource_with_multi_volume_work, user: user, state: 'metadata_review') }
  let(:parent_presenter) do
    ScannedResourceShowPresenter.new(
      SolrDocument.new(
        scanned_resource.to_solr
      ), nil
    )
  end

  context "an authorized user", vcr: { cassette_name: "locations", allow_playback_repeats: :multiple } do
    before(:each) do
      sign_in user
    end

    scenario "Logged in user can follow link to edit scanned resource" do
      visit polymorphic_path [scanned_resource]
      click_link 'Edit This Scanned Resource'
      expect(page).to have_text('Manage Your Work')
    end

    scenario "User can edit a scanned resource" do
      visit edit_polymorphic_path [scanned_resource]
      fill_in 'scanned_resource_source_metadata_identifier', with: '1234568'
      fill_in 'scanned_resource_portion_note', with: 'new portion note'
      fill_in 'scanned_resource_description', with: 'new description'
      fill_in 'scanned_resource_nav_date', with: '2016-04-01T01:01:01Z'
      select 'Color PDF', from: 'scanned_resource_pdf_type'
      choose 'Final Review'

      click_button 'Update Scanned resource'
      expect(page).to have_text("Test title")
      expect(page).to have_selector("span.label-primary", text: "Final Review")
    end

    scenario "User gets an error for bad metadata identifier change" do
      visit edit_polymorphic_path [scanned_resource]
      fill_in 'scanned_resource_source_metadata_identifier', with: 'badid'
      check "refresh_remote_metadata"

      click_button 'Update Scanned resource'
      expect(page).to have_text("Error retrieving metadata")
    end

    scenario "User can follow link to bulk edit scanned resource and add a new file" do
      allow(CharacterizeJob).to receive(:perform_later).once
      allow_any_instance_of(FileSet).to receive(:warn) # suppress virus warning messages

      visit polymorphic_path [scanned_resource]
      click_link I18n.t('file_manager.link_text')
      expect(page).to have_text(I18n.t('file_manager.link_text'))

      within("form.new_file_set") do
        attach_file("file_set[files][]", File.join(Rails.root, 'spec/fixtures/files/image.png'))
        click_on("Start upload")
      end

      visit polymorphic_path [parent_presenter.member_presenters.first]
      expect(page).to have_content "image.png"

      visit edit_polymorphic_path [scanned_resource]
      expect(page).not_to have_text('Representative Media')
    end
  end

  context "an anonymous user" do
    let(:scanned_resource) { FactoryGirl.create(:scanned_resource_with_multi_volume_work, user: user, state: 'complete') }
    scenario "User can't edit a scanned resource" do
      visit edit_polymorphic_path [scanned_resource]
      expect(page).to have_selector("div.alert-info", text: "You are not authorized to access this page")
    end

    scenario "User can follow link to parent multi volume work" do
      parent_id = scanned_resource.ordered_by.first.id
      visit curation_concerns_parent_scanned_resource_path(parent_id, scanned_resource.id)
      click_link 'Test title'
      expect(page).to have_text('Test title')
    end
  end
end
