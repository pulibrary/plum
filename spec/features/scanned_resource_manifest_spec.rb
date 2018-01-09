# frozen_string_literal: true
require 'rails_helper'

RSpec.feature "ScannedResourcesController", type: :feature do
  let(:user) { FactoryGirl.create(:image_editor) }
  let(:open_resource) { FactoryGirl.create(:complete_open_scanned_resource, user: user) }
  let(:private_resource) { FactoryGirl.create(:complete_private_scanned_resource, user: user) }

  context "an anonymous user" do
    scenario "views a public manifest" do
      visit manifest_hyrax_scanned_resource_path open_resource
      expect(page.status_code).to eq 200
    end

    scenario "views a private manifest" do
      visit manifest_hyrax_scanned_resource_path private_resource
      expect(page.status_code).to eq 401
    end
  end

  context "an authenticated user" do
    before do
      sign_in user
    end

    scenario "views a public manifest" do
      visit manifest_hyrax_scanned_resource_path open_resource
      expect(page.status_code).to eq 200
    end

    scenario "views a private manifest" do
      visit manifest_hyrax_scanned_resource_path private_resource
      expect(page.status_code).to eq 200
    end
  end
end
