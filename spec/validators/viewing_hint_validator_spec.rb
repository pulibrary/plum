require 'rails_helper'

RSpec.describe ViewingHintValidator do
  subject { described_class.new }

  describe "#validate" do
    let(:errors) { double("Errors") }
    before do
      allow(errors).to receive(:add)
    end
    [["individuals"], ["paged"], ["continuous"]].each do |direction|
      context "when viewing_hint is #{direction}" do
        it "does not add errors" do
          record = build_record(viewing_hint: direction)

          subject.validate(record)

          expect(errors).not_to have_received(:add)
        end
      end
    end

    context "when viewing direction is blank" do
      it "does not add errors" do
        record = build_record(viewing_hint: nil)

        subject.validate(record)

        expect(errors).not_to have_received(:add)
      end
    end

    context "when viewing direction is not acceptable" do
      it "adds errors" do
        record = build_record(viewing_hint: ["bad"])

        subject.validate(record)

        expect(errors).to have_received(:add).with(:viewing_hint, :inclusion, allow_blank: true, value: ["bad"])
      end
    end
  end

  def build_record(viewing_hint:)
    record = instance_double ScannedResource
    allow(record).to receive(:errors).and_return(errors)
    allow(record).to receive(:viewing_hint).and_return(viewing_hint)
    allow(record).to receive(:read_attribute_for_validation).with(:viewing_hint).and_return(record.viewing_hint)
    record
  end
end
