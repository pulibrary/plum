require 'rails_helper'

RSpec.describe RunWordBoundariesJob do
  let(:job) { described_class.new }

  before do
    mock_runner = double
    allow(mock_runner).to receive(:json_exists?) { true }
    allow(WordBoundariesRunner).to receive(:new).and_return(mock_runner)
  end

  describe "#perform" do
    context "word boundaries file already exists" do
      it "logs a message" do
        expect(Rails.logger).to receive(:info).with("WordBoundariesJob: 123")
        expect(Rails.logger).to receive(:info).with("WordBoundaries already exists for 123")
        job.perform('123')
      end
    end
  end
end
