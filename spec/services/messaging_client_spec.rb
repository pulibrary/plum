require 'rails_helper'

RSpec.describe MessagingClient do
  subject { described_class.new(url) }
  let(:url) { "amqp://test.x.z.s:4000" }
  describe "#publish" do
    context "when the URL is bad" do
      it "doesn't error" do
        expect { subject.publish("testing") }.not_to raise_error
      end
    end
  end
  describe "#enabled?" do
    context "when the URL is not blank" do
      it "returns true" do
        expect(subject.enabled?).to eq(true)
      end
    end
    context "when the URL is blank" do
      subject { described_class.new(nil) }
      it "returns false" do
        expect(subject.enabled?).to eq(false)
      end
    end
  end
end
