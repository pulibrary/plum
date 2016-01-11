require 'rails_helper'

RSpec.describe CatalogController do
  describe "scanned book display" do
    it "shows parent-less scanned resources" do
      resource = FactoryGirl.create(:scanned_resource)
      get :index, q: ""

      expect(document_ids).to eq [resource.id]
    end
    it "shows child-less parent resources" do
      work = FactoryGirl.create(:multi_volume_work)

      get :index, q: ""
      expect(document_ids).to eq [work.id]
    end
    it "hides scanned resources with parents" do
      work = FactoryGirl.build(:multi_volume_work)
      resource = FactoryGirl.create(:scanned_resource)
      work.ordered_members << resource
      work.save

      get :index, q: ""
      expect(document_ids).to eq [work.id]
    end
    it "finds parents with child metadata" do
      work = FactoryGirl.build(:multi_volume_work, title: ["Alpha"])
      resource = FactoryGirl.create(:scanned_resource, title: ["Beta"])
      work.ordered_members << resource
      work.save

      get :index, q: "Beta"
      expect(document_ids).to eq [work.id]
    end

    it "finds items by their identifier" do
      resource = FactoryGirl.create(:scanned_resource, source_metadata_identifier: "ab5")

      get :index, q: "ab5"

      expect(document_ids).to eq [resource.id]
    end

    it "finds items by metadata in their fileset" do
      file_set = FactoryGirl.create(:file_set, title: ["Screwdriver"])
      resource = FactoryGirl.build(:scanned_resource, title: ["Sonic"])
      resource.ordered_members << file_set
      resource.save!

      get :index, q: "Screwdriver"

      expect(document_ids).to eq [resource.id]
    end

    it "finds items by their section headings" do
      resource = FactoryGirl.build(:scanned_resource)
      resource.logical_order.order = {
        "nodes": [
          {
            "label": "The Doctor's Tales"
          }
        ]
      }
      resource.save!

      get :index, q: "Tales"

      expect(document_ids).to eq [resource.id]
    end
  end

  describe "resources in collections" do
    it "finds resources in a collection by the collection's slug" do
      resource = FactoryGirl.create(:scanned_resource_in_collection)
      resource.save

      get :index, q: "slug1"

      expect(document_ids).to eq [resource.id]
    end
  end

  def document_ids
    assigns[:document_list].map do |x|
      x["id"]
    end
  end
end
