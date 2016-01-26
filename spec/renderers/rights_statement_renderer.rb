require 'rails_helper'

RSpec.describe RightsStatementRenderer do
  let(:uri) { 'http://rightsstatements.org/vocab/InC/1.0/' }
  let(:label) { 'In Copyright' }
  let(:desc) { 'This Item is protected by copyright and/or related rights.' }
  let(:boilerplate) { 'Princeton University Library claims no copyright governing this digital resource.' }
  let(:rendered) { described_class.new([uri]).render }

  context "with a rendered rights statement" do
    it "includes the label and uri" do
      expect(rendered).to include(label)
      expect(rendered).to include(uri)
    end

    it "includes the description" do
      expect(rendered).to include(desc)
    end

    it "includes the generic boilerplate" do
      expect(rendered).to include(boilerplate)
    end
  end
end
