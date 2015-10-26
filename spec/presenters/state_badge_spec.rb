require 'rails_helper'

RSpec.describe StateBadge do
  subject { described_class.new(solr_document) }

  describe "pending" do
    let(:state) { "pending" }
    let(:solr_document) do
      instance_double(SolrDocument, state: state)
    end

    it "renders a badge" do
      expect(subject.render).to include("label-warning")
      expect(subject.render).to include("Pending")
    end
  end

  describe "complete" do
    let(:state) { "complete" }
    let(:solr_document) do
      instance_double(SolrDocument, state: state)
    end

    it "renders a badge" do
      expect(subject.render).to include("label-success")
      expect(subject.render).to include("Complete")
    end
  end
end
