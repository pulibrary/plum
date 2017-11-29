# frozen_string_literal: true
require 'rails_helper'

RSpec.describe StateBadge do
  subject { described_class.new(work_presenter) }
  let(:work_presenter) { ScannedResourceShowPresenter.new(scanned_resource, nil) }

  describe "pending" do
    let(:scanned_resource) { FactoryGirl.create(:pending_scanned_resource) }

    it "renders a badge" do
      expect(subject.render).to include("label-default")
      expect(subject.render).to include("Pending")
    end
  end

  describe "needs_qa" do
    let(:scanned_resource) { FactoryGirl.create(:needs_qa_ephemera_folder) }

    it "renders a badge" do
      expect(subject.render).to include("label-info")
      expect(subject.render).to include("Needs QA")
    end
  end

  describe "ready_to_ship" do
    let(:scanned_resource) { FactoryGirl.create(:ready_to_ship_box) }

    it "renders a badge" do
      expect(subject.render).to include("label-info")
      expect(subject.render).to include("Ready to Ship")
    end
  end

  describe "shipped" do
    let(:scanned_resource) { FactoryGirl.create(:shipped_box) }

    it "renders a badge" do
      expect(subject.render).to include("label-info")
      expect(subject.render).to include("Shipped")
    end
  end

  describe "received" do
    let(:scanned_resource) { FactoryGirl.create(:received_box) }

    it "renders a badge" do
      expect(subject.render).to include("label-default")
      expect(subject.render).to include("Received")
    end
  end

  describe "all_in_production" do
    let(:scanned_resource) { FactoryGirl.create(:all_in_production_box) }

    it "renders a badge" do
      expect(subject.render).to include("label-success")
      expect(subject.render).to include("All in Production")
    end
  end

  describe "metadata_review" do
    let(:scanned_resource) { FactoryGirl.create(:metadata_review_scanned_resource) }

    it "renders a badge" do
      expect(subject.render).to include("label-info")
      expect(subject.render).to include("Metadata Review")
    end
  end

  describe "final_review" do
    let(:scanned_resource) { FactoryGirl.create(:final_review_scanned_resource) }

    it "renders a badge" do
      expect(subject.render).to include("label-primary")
      expect(subject.render).to include("Final Review")
    end
  end

  describe "complete" do
    let(:scanned_resource) { FactoryGirl.create(:complete_scanned_resource) }

    it "renders a badge" do
      expect(subject.render).to include("label-success")
      expect(subject.render).to include("Complete")
    end
  end

  describe "flagged" do
    let(:scanned_resource) { FactoryGirl.create(:flagged_scanned_resource) }

    it "renders a badge" do
      expect(subject.render).to include("label-warning")
      expect(subject.render).to include("Flagged")
    end
  end

  describe "takedown" do
    let(:scanned_resource) { FactoryGirl.create(:takedown_scanned_resource) }

    it "renders a badge" do
      expect(subject.render).to include("label-danger")
      expect(subject.render).to include("Takedown")
    end
  end
end
