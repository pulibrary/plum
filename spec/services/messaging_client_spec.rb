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
end
