require 'rails_helper'

RSpec.describe RunWordBoundariesJob do
  let(:job) { described_class.new }

  before do
    allow(WordBoundariesRunner).to receive(:json_exists?).and_return(true)
  end

  describe "#perform" do
    context "word boundaries file already exists" do
      it "logs a message" do
        expect(Rails.logger).to receive(:info).with("WordBoundaries already exists for 123")
        job.perform(123)
      end
    end
  end
end
