require 'rails_helper'

RSpec.describe RightsStatementRenderer do
  let(:note) { 'This is a rights note' }

  context "with a rendered rights statement" do
    let(:uri) { 'http://rightsstatements.org/vocab/InC/1.0/' }
    let(:label) { 'In Copyright' }
    let(:rendered) { described_class.new([uri], note).render }

    it "includes the label and uri" do
      expect(rendered).to include(label)
      expect(rendered).to include(uri)
    end

    it "does not include the note" do
      expect(rendered).not_to include(note)
    end
  end

  context "with a InC-RUU rights statement" do
    let(:uri) { 'http://rightsstatements.org/vocab/InC-RUU/1.0/' }
    let(:label) { 'In Copyright - Rights-holder(s) Unlocatable or Unidentifiable' }
    let(:rendered) { described_class.new([uri], [note]).render }

    it "includes the label and uri" do
      expect(rendered).to include(label)
      expect(rendered).to include(uri)
    end

    it "includes the note" do
      expect(rendered).to include(note)
    end
  end

  context "with a No Copyright-Non-Commercial Use Only" do
    let(:uri) { 'http://rightsstatements.org/vocab/NoC-NC/1.0/' }
    let(:label) { 'No Copyright - Non-Commercial Use Only' }
    let(:rendered) { described_class.new([uri], [note]).render }

    it "includes the label and uri" do
      expect(rendered).to include(label)
      expect(rendered).to include(uri)
    end
  end
end
