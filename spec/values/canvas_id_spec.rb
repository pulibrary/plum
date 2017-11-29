# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CanvasID do
  subject { described_class.new(id, parent_path) }
  let(:parent_path) { "http://test.com/manifest" }
  let(:id) { "1" }

  describe "#to_s" do
    it "returns a good path" do
      expect(subject.to_s).to eq "http://test.com/manifest/canvas/1"
    end
  end
end
