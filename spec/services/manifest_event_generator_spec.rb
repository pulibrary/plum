require 'rails_helper'

RSpec.describe ManifestEventGenerator do
  subject { described_class.new(rabbit_connection) }
  let(:rabbit_connection) { instance_double(MessagingClient, publish: true) }
  let(:record) { FactoryGirl.build(:scanned_resource) }
  describe "#record_created" do
    it "publishes a persistent JSON message" do
      record.save
      expected_result = {
        "id" => record.id,
        "event" => "CREATED",
        "manifest_url" => "http://plum.com/concern/scanned_resources/#{record.id}/manifest",
        "collection_slugs" => []
      }

      subject.record_created(record)

      expect(rabbit_connection).to have_received(:publish).with(expected_result.to_json)
    end
    it "embeds collection memberships" do
      record.save!
      collection = FactoryGirl.create(:collection, ordered_members: [record])
      expected_result = {
        "id" => record.id,
        "event" => "CREATED",
        "manifest_url" => "http://plum.com/concern/scanned_resources/#{record.id}/manifest",
        "collection_slugs" => [collection.exhibit_id]
      }

      subject.record_created(record)

      expect(rabbit_connection).to have_received(:publish).with(expected_result.to_json)
    end
  end

  describe "#record_deleted" do
    it "publishes a persistent JSON message" do
      record.save
      record.destroy
      expected_result = {
        "id" => record.id,
        "event" => "DELETED",
        "manifest_url" => "http://plum.com/concern/scanned_resources/#{record.id}/manifest"
      }

      subject.record_deleted(record)

      expect(rabbit_connection).to have_received(:publish).with(expected_result.to_json)
    end
  end

  describe "#record_updated" do
    it "publishes a persistent JSON message with collection memberships" do
      record.save!
      collection = FactoryGirl.create(:collection, ordered_members: [record])
      expected_result = {
        "id" => record.id,
        "event" => "UPDATED",
        "manifest_url" => "http://plum.com/concern/scanned_resources/#{record.id}/manifest",
        "collection_slugs" => [collection.exhibit_id]
      }

      subject.record_updated(record)

      expect(rabbit_connection).to have_received(:publish).with(expected_result.to_json)
    end
  end
end
