require 'rails_helper'

RSpec.describe CatalogController do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in user
  end

  describe "scanned book display" do
    it "shows parent-less scanned resources" do
      resource = FactoryGirl.create(:complete_scanned_resource)
      get :index, params: { q: "" }
      expect(document_ids).to eq [resource.id]
    end
    it "shows child-less parent resources" do
      work = FactoryGirl.create(:complete_multi_volume_work)

      get :index, params: { q: "" }
      expect(document_ids).to eq [work.id]
    end
    it "hides scanned resources with parents" do
      work = FactoryGirl.create(:complete_multi_volume_work)
      resource = FactoryGirl.create(:complete_scanned_resource)
      work.ordered_members << resource
      work.save
      resource.save

      get :index, params: { q: "" }
      expect(document_ids).to eq [work.id]
    end
    it "finds parents with child metadata, even with multiple words in title" do
      work = FactoryGirl.create(:complete_multi_volume_work, title: ["Alpha"])
      resource = FactoryGirl.create(:complete_scanned_resource, title: ["Beta Gamma"])
      work.ordered_members << resource
      work.save
      resource.save

      get :index, params: { q: "Beta Gamma" }
      expect(document_ids).to eq [work.id]
    end

    it "finds parents with child fileset full text" do
      work = FactoryGirl.create(:complete_multi_volume_work, title: ["Alpha"])
      file_set = FactoryGirl.build(:file_set, title: ["Screwdriver"])
      allow(file_set).to receive(:ocr_text).and_return("informatica")
      resource = FactoryGirl.create(:complete_scanned_resource, title: ["Beta"])
      resource.ordered_members << file_set
      resource.save!
      file_set.save
      work.ordered_members << resource
      work.save
      resource.save

      get :index, params: { q: "informatica" }
      expect(document_ids).to eq [work.id]
    end

    it "finds items by their identifier" do
      resource = FactoryGirl.create(:complete_scanned_resource, source_metadata_identifier: "ab5")

      get :index, params: { q: "ab5" }

      expect(document_ids).to eq [resource.id]
    end

    it "finds items by metadata in their fileset" do
      file_set = FactoryGirl.build(:file_set, title: ["Screwdriver"])
      resource = FactoryGirl.create(:complete_scanned_resource, title: ["Sonic"])
      resource.ordered_members << file_set
      resource.save!
      file_set.save

      get :index, params: { q: "Screwdriver" }

      expect(document_ids).to eq [resource.id]
    end

    it "finds items by metadata in their fileset's full text" do
      file_set = FactoryGirl.build(:file_set, title: ["Screwdriver"])
      allow(file_set).to receive(:ocr_text).and_return("informatica")
      file_set.save
      resource = FactoryGirl.create(:complete_scanned_resource, title: ["Sonic"])
      resource.ordered_members << file_set
      resource.save!
      file_set.save

      get :index, params: { q: "informatica" }

      expect(document_ids).to eq [resource.id]
    end

    it "finds items by their section headings" do
      resource = FactoryGirl.create(:complete_scanned_resource)
      resource.logical_order.order = {
        "nodes": [
          {
            "label": "The Doctor's Tales"
          }
        ]
      }
      resource.save!

      get :index, params: { q: "Tales" }

      expect(document_ids).to eq [resource.id]
    end

    it "hides items the user can't read" do
      FactoryGirl.create(:pending_scanned_resource)
      get :index, params: { q: "" }

      expect(document_ids).to eq []
    end
  end

  describe "resources in collections" do
    it "finds resources in a collection by the collection's slug" do
      resource = FactoryGirl.create(:complete_scanned_resource_in_collection)
      resource.save

      get :index, params: { q: resource.member_of_collections.first.exhibit_id }

      expect(document_ids).to eq [resource.id]
    end
  end

  def document_ids
    assigns[:document_list].map do |x|
      x["id"]
    end
  end
end
