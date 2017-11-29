# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "AuthTokens", type: :request do
  describe "GET /auth_tokens" do
    it "works! (now write some real specs)" do
      get auth_tokens_path
      expect(response).to have_http_status(200)
    end
  end
end
