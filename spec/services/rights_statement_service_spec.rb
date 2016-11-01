require 'rails_helper'

RSpec.describe RightsStatementService do
  let(:uri) { 'http://rightsstatements.org/vocab/InC/1.0/' }
  let(:desc) { 'This Item is protected by copyright and/or related rights.' }
  let(:valid_statements) {
    [
      'http://rightsstatements.org/vocab/InC/1.0/',
      'http://rightsstatements.org/vocab/InC-RUU/1.0/',
      'http://rightsstatements.org/vocab/InC-EDU/1.0/',
      'http://rightsstatements.org/vocab/InC-NC/1.0/',
      'http://rightsstatements.org/vocab/NoC-CR/1.0/',
      'http://rightsstatements.org/vocab/NoC-OKLR/1.0/',
      'http://rightsstatements.org/vocab/NKC/1.0/'
    ]
  }

  context "rights statements" do
    it "provides definitions of rights statements" do
      expect(described_class.new.definition(uri)).to include(desc)
      expect(described_class.new.definition(uri)).to include('<br/>')
    end

    it "lists all valid rights statements" do
      expect(described_class.new.valid_statements).to eq(valid_statements)
    end

    it "lists select options" do
      expect(described_class.new.select_options).to include ['No Known Copyright', 'http://rightsstatements.org/vocab/NKC/1.0/']
    end
  end
end
