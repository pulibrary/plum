# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ServesLinkedData do
  before do
    class LinkedController < ApplicationController
      include ServesLinkedData
    end
  end
  after do
    Object.send(:remove_const, :LinkedController)
  end
  describe "export_as_json" do
    it "has no properties by default" do
      expect(LinkedController.new.export_as_jsonld).to eq({})
    end
  end
end
