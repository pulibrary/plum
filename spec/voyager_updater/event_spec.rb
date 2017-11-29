# frozen_string_literal: true
require 'rails_helper'

RSpec.describe VoyagerUpdater::Event, vcr: { cassette_name: 'voyager_dump' } do
  subject { described_class.new(json) }
  let(:json) do
    {
      id: 1096,
      start: "2016-03-09T03:37:45.000Z",
      finish: "2016-03-09T03:45:48.000Z",
      success: true,
      error: nil,
      dump_type: dump_type,
      dump_url: "https://bibdata.princeton.edu/dumps/1081.json"
    }.stringify_keys
  end
  let(:dump_type) { "CHANGED_RECORDS" }
  describe "#id" do
    it "returns the ID" do
      expect(subject.id).to eq 1096
    end
  end

  describe "#dump_type" do
    it "returns the type" do
      expect(subject.dump_type).to eq "CHANGED_RECORDS"
    end
  end

  describe "#processed?" do
    context "when there's no processed event" do
      it "returns false" do
        expect(subject).not_to be_processed
      end
    end
    context "when there's a processed event" do
      it "returns true" do
        ProcessedEvent.create(event_id: 1096)

        expect(subject).to be_processed
      end
    end
  end

  describe "#process!" do
    it "updates all changed records" do
      s = FactoryGirl.create(:complete_scanned_resource, source_metadata_identifier: ["359850"])
      subject.process!

      expect(s.reload.title.first.to_s).to eq "Coda"
      expect(subject).to be_processed
    end
    context "when processed" do
      it "doesn't reprocess" do
        allow(VoyagerUpdater::Processor).to receive(:new)
        ProcessedEvent.create(event_id: 1096)

        subject.process!
        expect(VoyagerUpdater::Processor).not_to have_received(:new)
      end
    end
    context "when dump type isn't changed_records" do
      let(:dump_type) { "ALL_RECORDS" }
      it "doesn't process" do
        allow(VoyagerUpdater::Processor).to receive(:new)

        subject.process!
        expect(VoyagerUpdater::Processor).not_to have_received(:new)
      end
    end
  end

  describe "#dump" do
    it "returns a dump object" do
      expect(subject.dump).to be_kind_of VoyagerUpdater::Dump
      expect(subject.dump.url).to eq json["dump_url"]
    end
  end
end
