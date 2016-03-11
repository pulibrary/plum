require 'rails_helper'

RSpec.describe VoyagerUpdater::EventStream, vcr: { cassette_name: 'voyager_dump' } do
  subject { described_class.new(url) }
  let(:url) { "https://bibdata.princeton.edu/events.json" }
  describe "#events" do
    it "is a bunch of Events" do
      expect(subject.events.map(&:class).uniq).to eq [VoyagerUpdater::Event]
      expect(subject.events.length).to eq 3
    end
  end

  describe "#process!" do
    it "updates all changed records and fires events" do
      s = FactoryGirl.create(:scanned_resource, source_metadata_identifier: "359850")
      manifest_event_generator = instance_double(ManifestEventGenerator)
      allow(ManifestEventGenerator).to receive(:new).and_return(manifest_event_generator)
      allow(manifest_event_generator).to receive(:record_updated)
      subject.process!

      expect(s.reload.title).to eq ["Coda"]
      expect(manifest_event_generator).to have_received(:record_updated).with(s)
    end
  end
end
