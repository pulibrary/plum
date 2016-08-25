require 'rails_helper'

RSpec.describe RightsStatementRenderer do
  let(:note) { 'This is a rights note' }
  let(:boilerplate) { 'Indiana University claims no copyright governing this digital resource.' }

  context "with a rendered rights statement" do
    let(:uri) { 'http://rightsstatements.org/vocab/InC/1.0/' }
    let(:label) { 'In Copyright' }
    let(:desc) { 'This Item is protected by copyright and/or related rights.' }
    let(:rendered) { described_class.new([uri], note).render }

    it "includes the label and uri" do
      expect(rendered).to include(label)
      expect(rendered).to include(uri)
    end

    it "includes the description" do
      expect(rendered).to include(desc)
    end

    it "does not include the note" do
      expect(rendered).not_to include(note)
    end

    it "includes the generic boilerplate" do
      expect(rendered).to include(boilerplate)
    end
  end

  context "with a InC-RUU rights statement" do
    let(:uri) { 'http://rightsstatements.org/vocab/InC-RUU/1.0/' }
    let(:label) { 'In Copyright - Rights-holder(s) Unlocatable or Unidentifiable' }
    let(:desc) { 'However, for this Item, either (a) no rights-holder(s) have been identified' }
    let(:rendered) { described_class.new([uri], [note]).render }

    it "includes the label and uri" do
      expect(rendered).to include(label)
      expect(rendered).to include(uri)
    end

    it "includes the description" do
      expect(rendered).to include(desc)
    end

    it "includes the note" do
      expect(rendered).to include(note)
    end

    it "includes the generic boilerplate" do
      expect(rendered).to include(boilerplate)
    end
  end
end
