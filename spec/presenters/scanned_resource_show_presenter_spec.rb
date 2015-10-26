require 'rails_helper'

RSpec.describe ScannedResourceShowPresenter do
  subject { described_class.new(solr_document, ability) }

  let(:date_created) { "2015-09-02" }
  let(:state) { "pending" }
  let(:solr_document) do
    instance_double(SolrDocument, date_created: date_created, state: state)
  end
  let(:ability) { nil }

  describe "#date_created" do
    it "delegates to solr document" do
      expect(subject.date_created).to eq date_created
    end
  end
  describe "#state" do
    it "delegates to solr document" do
      expect(subject.state).to eq state
    end
  end
end
