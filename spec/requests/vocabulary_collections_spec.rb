require 'rails_helper'

RSpec.describe "VocabularyCollections", type: :request do
  describe "GET /vocabulary_collections" do
    it "works! (now write some real specs)" do
      get vocabulary_collections_path
      expect(response).to have_http_status(200)
    end
  end
end
