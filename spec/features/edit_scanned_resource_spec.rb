# frozen_string_literal: true
require 'rails_helper'

RSpec.feature "ScannedResourcesController", type: :feature, admin_set: true do
  let(:user) { FactoryGirl.create(:image_editor) }
  let(:scanned_resource) { FactoryGirl.create(:metadata_review_scanned_resource_with_multi_volume_work, user: user) }
  let(:parent_presenter) do
    ScannedResourceShowPresenter.new(
      SolrDocument.new(
        scanned_resource.to_solr
      ), nil
    )
  end

  context "an authorized user", vcr: { cassette_name: "locations", allow_playback_repeats: :multiple } do
    before do
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
      fill_in 'scanned_resource_nav_date', with: '2016-04-01T01:01:01Z'
      select 'Color PDF', from: 'scanned_resource_pdf_type'

      click_button 'Save'
      expect(page).to have_text("Test title")
    end

    scenario "User gets an error for bad metadata identifier change" do
      visit edit_polymorphic_path [scanned_resource]
      fill_in 'scanned_resource_source_metadata_identifier', with: 'badid'
      check "refresh_remote_metadata"

      click_button 'Save'
      expect(page).to have_text("Error retrieving metadata")
    end

    let(:file1) { File.open(Rails.root.join("spec", "fixtures", "files", "gray.tif")) }
    let(:uploaded_file1) { Hyrax::UploadedFile.create(file: file1, user: user) }
  end

  context "an anonymous user" do
    let(:scanned_resource) { FactoryGirl.create(:complete_scanned_resource_with_multi_volume_work, user: user) }
    scenario "User can't edit a scanned resource" do
      visit edit_polymorphic_path [scanned_resource]
      expect(page).to have_content "Unauthorized"
    end

    scenario "User can follow link to parent multi volume work" do
      parent_id = scanned_resource.ordered_by.first.id
      visit hyrax_parent_scanned_resource_path(parent_id, scanned_resource.id)
      click_link 'Test title'
      expect(page).to have_text('Test title')
    end
  end
end
