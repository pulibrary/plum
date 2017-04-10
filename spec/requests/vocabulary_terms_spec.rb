require 'rails_helper'

RSpec.describe "VocabularyTerms", type: :request do
  describe "GET /vocabulary_terms" do
    it "works! (now write some real specs)" do
      get vocabulary_terms_path
      expect(response).to have_http_status(200)
    end
  end
end
