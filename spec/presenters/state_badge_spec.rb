require 'rails_helper'

RSpec.describe StateBadge do
  describe "pending" do
    subject { described_class.new('type', 'pending') }

    it "renders a badge" do
      expect(subject.render).to include("label-default")
      expect(subject.render).to include("Pending")
    end
  end

  describe "metadata_review" do
    subject { described_class.new('type', 'metadata_review') }

    it "renders a badge" do
      expect(subject.render).to include("label-info")
      expect(subject.render).to include("Metadata Review")
    end
  end

  describe "final_review" do
    subject { described_class.new('type', 'final_review') }

    it "renders a badge" do
      expect(subject.render).to include("label-primary")
      expect(subject.render).to include("Final Review")
    end
  end

  describe "complete" do
    subject { described_class.new('type', 'complete') }

    it "renders a badge" do
      expect(subject.render).to include("label-success")
      expect(subject.render).to include("Complete")
    end
  end

  describe "flagged" do
    subject { described_class.new('type', 'flagged') }

    it "renders a badge" do
      expect(subject.render).to include("label-warning")
      expect(subject.render).to include("Flagged")
    end
  end

  describe "takedown" do
    subject { described_class.new('type', 'takedown') }

    it "renders a badge" do
      expect(subject.render).to include("label-danger")
      expect(subject.render).to include("Takedown")
    end
  end
end
