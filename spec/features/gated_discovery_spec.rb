# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Gated Discovery', type: :feature do
  let(:public_resource) { FactoryGirl.create(:scanned_resource) }
  let(:private_resource) { FactoryGirl.create(:private_scanned_resource) }
  let(:public_collection) { FactoryGirl.create(:collection) }
  let(:private_collection) { FactoryGirl.create(:private_collection) }

  describe "public objects" do
    it "include public" do
      expect(public_resource.read_groups).to include('public')
      expect(public_collection.read_groups).to include('public')
    end
  end

  describe "private objects" do
    it "include authorized roles" do
      expect(private_resource.read_groups).to include('fulfiller')
      expect(private_collection.read_groups).to include('fulfiller')
    end
  end
end
