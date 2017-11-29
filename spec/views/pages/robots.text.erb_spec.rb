# frozen_string_literal: true
require 'rails_helper'

describe "pages/robots.text.erb" do
  context "when not in production" do
    before do
      allow(Rails.env).to receive(:production?).and_return(false)
      render
    end
    it "disallows all" do
      expect(response).to include "Disallow: /"
    end
  end
  context "when in production" do
    before do
      allow(Rails.env).to receive(:production?).and_return(true)
      render
    end
    it "does not disallow all" do
      expect(response).not_to include "Disallow: /"
    end
  end
end
