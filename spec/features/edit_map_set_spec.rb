# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'MapSetsController', type: :feature, admin_set: true do
  let(:user) { FactoryGirl.create(:image_editor) }
  let(:map_set) { FactoryGirl.create(:complete_map_set, user: user) }

  before do
    sign_in user
  end

  scenario 'Logged in user can follow link to edit map set work' do
    visit polymorphic_path [map_set]
    click_link 'Edit This Map Set'
    expect(page).to have_text('Manage Your Work')
  end

  scenario 'User can edit a map set', vcr: { cassette_name: "ezid" } do
    Ezid::Client.configure do |conf| conf.logger = Logger.new(File::NULL); end

    visit edit_polymorphic_path [map_set]
    fill_in 'map_set_source_metadata_identifier', with: '1234568'

    click_button 'Save'
    expect(page).to have_text('Test title')
  end

  scenario "User can create a new image work attached to the map set" do
    visit polymorphic_path [map_set]

    click_link 'Attach New Image Work'
    fill_in 'image_work_title', with: 'Sheet 1'
    select 'No Known Copyright', from: 'image_work_rights_statement'
    click_button 'Save'

    visit polymorphic_path [map_set]
    expect(page).to have_link('Sheet 1', count: 1)
  end
end
