require 'rails_helper'

RSpec.describe StateValidator do
  subject { described_class.new }

  describe "#validate" do
    let(:errors) { double("Errors") }
    before do
      allow(errors).to receive(:add)
    end
    ["pending", "metadata_review", "final_review", "complete", "flagged", "takedown"].each do |state|
      context "when state is #{state}" do
        it "does not add errors" do
          record = build_record(state, nil)

          subject.validate(record)

          expect(errors).not_to have_received(:add)
        end
      end
    end

    context "when state is blank" do
      it "does not add errors" do
        record = build_record(nil, nil)

        subject.validate(record)

        expect(errors).not_to have_received(:add)
      end
    end

    context "when state is not acceptable" do
      it "adds errors" do
        record = build_record("bad", "bad")

        subject.validate(record)

        expect(errors).to have_received(:add).with(:state, :inclusion, allow_blank: true, value: "bad")
      end
    end
  end

  def build_record(state, state_was)
    record = double "ScannedResource"
    allow(record).to receive(:errors).and_return(errors)
    allow(record).to receive(:state).and_return(state)
    allow(record).to receive(:read_attribute_for_validation).with(:state).and_return(record.state)
    allow(record).to receive(:state_changed?).and_return(state == state_was)
    allow(record).to receive(:state_was).and_return(state_was)
    record
  end
end
