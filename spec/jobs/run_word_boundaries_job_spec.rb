require 'rails_helper'

RSpec.describe RunWordBoundariesJob do
  let(:job) { described_class.new }

  describe "#perform" do
    context "word boundaries file already exists" do
      before do
        mock_runner = double
        allow(mock_runner).to receive(:json_exists?) { true }
        allow(WordBoundariesRunner).to receive(:new).and_return(mock_runner)
      end
      it "logs a message" do
        expect(Rails.logger).to receive(:info).with("WordBoundariesJob: 123")
        expect(Rails.logger).to receive(:info).with("WordBoundaries already exists for 123")
        job.perform('123')
      end
    end
    context "hocr file exists" do
      before do
        @mock_runner = double
        allow(@mock_runner).to receive(:json_exists?) { false }
        allow(@mock_runner).to receive(:hocr_exists?) { true }
        allow(@mock_runner).to receive(:create) { nil }
        allow(WordBoundariesRunner).to receive(:new).and_return(@mock_runner)
      end
      it "creates a WordBoundariesRunner" do
        expect(Rails.logger).to receive(:info).with("WordBoundariesJob: 123")
        expect(@mock_runner).to receive(:create)
        job.perform('123')
      end
    end
    context "conditions not met for word boundaries file creation" do
      before do
        mock_runner = double
        mock_job = double
        allow(mock_runner).to receive(:json_exists?) { false }
        allow(mock_runner).to receive(:hocr_exists?) { false }
        allow(mock_job).to receive(:perform_later)
        allow(WordBoundariesRunner).to receive(:new).and_return(mock_runner)
        allow(described_class).to receive(:set) { mock_job }
      end
      it "logs a message and set up to run later" do
        expect(Rails.logger).to receive(:info).with("WordBoundariesJob: 123")
        expect(Rails.logger).to receive(:info).with("WordBoundariesJob: Preconditions not met 123")
        expect(described_class).to receive(:set)
        job.perform('123')
      end
    end
  end
end
