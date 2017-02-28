require 'rails_helper'

RSpec.describe RightsStatementRenderer do
  let(:note) { 'This is a rights note' }
  let(:boilerplate) { 'Princeton University Library claims no copyright governing this digital resource.' }

  context "with the default rights statement" do
    let(:uri) { 'http://rightsstatements.org/vocab/NKC/1.0/' }
    let(:label) { 'No Known Copyright' }
    let(:desc) { 'Princeton University Library reasonably believes that the Item is not restricted by copyright' }
    let(:rendered) { described_class.new([uri], [note]).render }

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

  context "with a notable rights statement" do
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
