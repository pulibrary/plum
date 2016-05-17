require 'rails_helper'

RSpec.describe HOCRDocument do
  subject { described_class.new(document) }
  let(:document) { File.open(Rails.root.join("spec", "fixtures", "files", "test.hocr")) }

  describe "#text" do
    it "returns the combined text" do
      expect(subject.text).to eq "\n \n  \n\n\n  \n  \n\n\n  \n   \n    \n     Studio per l’elaborazione informatica delle fonti storico—artistiche \n     \n    \n   \n  \n\n"
    end
  end

  describe "#bounding_box" do
    it "doesn't return anything" do
      expect(subject.bounding_box.top_left.x).to eq nil
      expect(subject.bounding_box.top_left.y).to eq nil
      expect(subject.bounding_box.bottom_right.x).to eq nil
      expect(subject.bounding_box.bottom_right.y).to eq nil
    end
  end

  describe "#pages" do
    it "returns pages" do
      expect(subject.pages.length).to eq 1

      expect(subject.pages.first.bounding_box.top_left.x).to eq 0
      expect(subject.pages.first.bounding_box.top_left.y).to eq 0
      expect(subject.pages.first.bounding_box.bottom_right.x).to eq 4958
      expect(subject.pages.first.bounding_box.bottom_right.y).to eq 7017
    end
  end

  describe "#areas" do
    context "when they're deep" do
      it "returns them" do
        expect(subject.areas.length).to eq 1
      end
    end
    context "when there is one" do
      subject { described_class.new(document).pages.first }
      it "returns it" do
        expect(subject.areas.length).to eq 1

        first_area = subject.areas.first
        expect(first_area.bounding_box.top_left.x).to eq 471
        expect(first_area.bounding_box.top_left.y).to eq 727
        expect(first_area.bounding_box.bottom_right.x).to eq 4490
        expect(first_area.bounding_box.bottom_right.y).to eq 6710
      end
    end
  end

  describe "#paragraphs" do
    context "when they're deep" do
      it "returns them" do
        expect(subject.paragraphs.length).to eq 1
      end
    end
    context "when there is one" do
      subject { described_class.new(document).pages.first.areas.first }
      it "returns it" do
        expect(subject.paragraphs.length).to eq 1

        first_paragraph = subject.paragraphs.first
        expect(first_paragraph.bounding_box.top_left.x).to eq 1390
        expect(first_paragraph.bounding_box.top_left.y).to eq 727
        expect(first_paragraph.bounding_box.bottom_right.x).to eq 3571
        expect(first_paragraph.bounding_box.bottom_right.y).to eq 1035
      end
    end
  end

  describe "#lines" do
    context "when they're deep" do
      it "returns them" do
        expect(subject.lines.length).to eq 1
      end
    end
    context "when there is one" do
      subject { described_class.new(document).pages.first.areas.first.paragraphs.first }
      it "returns it" do
        expect(subject.lines.length).to eq 1

        first_paragraph = subject.lines.first
        expect(first_paragraph.bounding_box.top_left.x).to eq 1390
        expect(first_paragraph.bounding_box.top_left.y).to eq 960
        expect(first_paragraph.bounding_box.bottom_right.x).to eq 3571
        expect(first_paragraph.bounding_box.bottom_right.y).to eq 1035
      end
    end
  end
end
