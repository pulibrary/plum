# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Vocabularies", type: :request do
  describe "GET /vocabularies" do
    it "works! (now write some real specs)" do
      get vocabularies_path
      expect(response).to have_http_status(200)
    end
  end
end
