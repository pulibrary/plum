require 'rails_helper'

RSpec.describe RightsStatementValidator do
  subject { described_class.new }

  describe "#validate" do
    let(:errors) { double("Errors") }
    valid_statements = [
      'http://rightsstatements.org/vocab/InC/1.0/',
      'http://rightsstatements.org/vocab/InC-RUU/1.0/',
      'http://rightsstatements.org/vocab/InC-EDU/1.0/',
      'http://rightsstatements.org/vocab/InC-NC/1.0/',
      'http://rightsstatements.org/vocab/NoC-CR/1.0/',
      'http://rightsstatements.org/vocab/NoC-OKLR/1.0/',
      'http://rightsstatements.org/vocab/NKC/1.0/'
    ]
    before do
      allow(errors).to receive(:add)
    end
    valid_statements.each do |statement|
      context "when rights_statement is #{statement}" do
        it "does not add errors" do
          record = build_record(rights_statement: [statement])

          subject.validate(record)

          expect(errors).not_to have_received(:add)
        end
      end
    end

    context "when rights statement is blank" do
      it "add errors" do
        record = build_record(rights_statement: nil)

        subject.validate(record)

        expect(errors).to have_received(:add).with(:rights_statement, :inclusion, allow_blank: false, value: nil)
      end
    end

    context "when rights statement is not acceptable" do
      it "adds errors" do
        record = build_record(rights_statement: "bad")

        subject.validate(record)

        expect(errors).to have_received(:add).with(:rights_statement, :inclusion, allow_blank: false, value: "bad")
      end
    end
  end

  def build_record(rights_statement:)
    record = instance_double ScannedResource
    allow(record).to receive(:errors).and_return(errors)
    allow(record).to receive(:rights_statement).and_return(rights_statement)
    allow(record).to receive(:read_attribute_for_validation).with(:rights_statement).and_return(record.rights_statement)
    record
  end
end
