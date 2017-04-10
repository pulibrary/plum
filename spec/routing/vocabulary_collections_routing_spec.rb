require "rails_helper"

RSpec.describe VocabularyCollectionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/vocabulary_collections").to route_to("vocabulary_collections#index")
    end

    it "routes to #new" do
      expect(get: "/vocabulary_collections/new").to route_to("vocabulary_collections#new")
    end

    it "routes to #show" do
      expect(get: "/vocabulary_collections/1").to route_to("vocabulary_collections#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/vocabulary_collections/1/edit").to route_to("vocabulary_collections#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/vocabulary_collections").to route_to("vocabulary_collections#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/vocabulary_collections/1").to route_to("vocabulary_collections#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/vocabulary_collections/1").to route_to("vocabulary_collections#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/vocabulary_collections/1").to route_to("vocabulary_collections#destroy", id: "1")
    end
  end
end
