require 'rails_helper'

RSpec.describe RightsStatementService do
  let(:uri) { 'http://rightsstatements.org/vocab/InC/1.0/' }
  let(:valid_statements) {
    [
      'http://rightsstatements.org/vocab/InC/1.0/',
      'http://rightsstatements.org/vocab/InC-RUU/1.0/',
      'http://rightsstatements.org/vocab/InC-EDU/1.0/',
      'http://rightsstatements.org/vocab/InC-NC/1.0/',
      'http://rightsstatements.org/vocab/NoC-CR/1.0/',
      'http://rightsstatements.org/vocab/NoC-OKLR/1.0/',
      'http://rightsstatements.org/vocab/NoC-NC/1.0/',
      'http://rightsstatements.org/vocab/NKC/1.0/'
    ]
  }

  context "rights statements" do
    it "lists all valid rights statements" do
      expect(described_class.valid_statements).to eq(valid_statements)
    end
  end
end
