require 'rails_helper'

RSpec.describe HOCRDocument do
  subject { described_class.new(document) }
  let(:document) { File.open(Rails.root.join("spec", "fixtures", "files", "test.hocr")) }

  describe "#text" do
    it "returns the combined text" do
      expect(subject.text).to eq "\n   \n    \n     Studio per lâ\u0080\u0099elaborazione informatica delle fonti storicoâ\u0080\u0094artistiche \n     \n    \n   \n  \n"
    end
  end

  describe "#bounding_box" do
    it "returns the bounding box of the entire document" do
      expect(subject.bounding_box.top_left.x).to eq 0
      expect(subject.bounding_box.top_left.y).to eq 0
      expect(subject.bounding_box.bottom_right.x).to eq 4958
      expect(subject.bounding_box.bottom_right.y).to eq 7017
    end
  end
end
