require 'rails_helper'

RSpec.describe StateValidator do
  subject { described_class.new }

  describe "#validate" do
    let(:errors) { double("Errors") }
    before do
      allow(errors).to receive(:add)
    end
    ["complete", "pending"].each do |state|
      context "when state is #{state}" do
        it "does not add errors" do
          record = build_record(state: state)

          subject.validate(record)

          expect(errors).not_to have_received(:add)
        end
      end
    end

    context "when state is blank" do
      it "does not add errors" do
        record = build_record(state: nil)

        subject.validate(record)

        expect(errors).not_to have_received(:add)
      end
    end

    context "when state is not acceptable" do
      it "adds errors" do
        record = build_record(state: "bad")

        subject.validate(record)

        expect(errors).to have_received(:add).with(:state, :inclusion, allow_blank: true, value: "bad")
      end
    end
  end

  def build_record(state:)
    record = instance_double ScannedResource
    allow(record).to receive(:errors).and_return(errors)
    allow(record).to receive(:state).and_return(state)
    allow(record).to receive(:read_attribute_for_validation).with(:state).and_return(record.state)
    record
  end
end
