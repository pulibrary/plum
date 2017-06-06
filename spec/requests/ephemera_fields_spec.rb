require 'rails_helper'

RSpec.describe "EphemeraFields", type: :request do
  describe "GET /ephemera_fields" do
    it "works! (now write some real specs)" do
      get ephemera_fields_path
      expect(response).to have_http_status(200)
    end
  end
end
