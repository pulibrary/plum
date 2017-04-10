require "rails_helper"

RSpec.describe VocabularyTermsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/vocabulary_terms").to route_to("vocabulary_terms#index")
    end

    it "routes to #new" do
      expect(get: "/vocabulary_terms/new").to route_to("vocabulary_terms#new")
    end

    it "routes to #show" do
      expect(get: "/vocabulary_terms/1").to route_to("vocabulary_terms#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/vocabulary_terms/1/edit").to route_to("vocabulary_terms#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/vocabulary_terms").to route_to("vocabulary_terms#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/vocabulary_terms/1").to route_to("vocabulary_terms#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/vocabulary_terms/1").to route_to("vocabulary_terms#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/vocabulary_terms/1").to route_to("vocabulary_terms#destroy", id: "1")
    end
  end
end
