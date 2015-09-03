require 'rails_helper'

RSpec.feature "ScannedBooksController", type: :feature do
  let(:user) { FactoryGirl.create(:scanned_book_creator) }
  let(:scanned_book) { FactoryGirl.create(:scanned_book, user: user) }

  before(:each) do
    sign_in user
  end

  scenario "Logged in user can follow link to edit scanned book" do
    visit polymorphic_path [:curation_concerns, scanned_book]
    click_link 'Edit This Scanned Book'
    expect(page).to have_text('Manage Your Work')
  end

  scenario "User can edit a scanned book" do
    visit edit_polymorphic_path [:curation_concerns, scanned_book]
    fill_in 'scanned_book_source_metadata_identifier', with: '1234568'
    fill_in 'scanned_book_portion_note', with: 'new portion note'
    fill_in 'scanned_book_description', with: 'new description'
    click_button 'Update Scanned book'
    expect(page).to have_text("Test title (Scanned Book)")
  end

  scenario "User can add a new file" do
    allow(CharacterizeJob).to receive(:perform_later).once

    visit polymorphic_path [:curation_concerns, scanned_book]
    click_link 'Attach a File'

    within("form.new_generic_file") do
      fill_in("Title", with: 'image.png')
      attach_file("Upload a file", File.join(Rails.root, 'spec/fixtures/files/image.png'))
      click_on("Attach to Scanned Book")
    end

    within '.related_files' do
      expect(page).to have_link "image.png"
    end
  end
end
