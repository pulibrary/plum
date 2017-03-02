require 'rails_helper'

RSpec.describe ScannedResourceShowPresenter do
  subject { described_class.new(solr_document, ability) }

  let(:date_created) { "2015-09-02" }
  let(:state) { "pending" }
  let(:title) { "test title" }
  let(:solr_document) do
    instance_double(SolrDocument, date_created: date_created, id: "test", title: title)
  end
  let(:ability) { nil }

  describe "#date_created" do
    it "delegates to solr document" do
      expect(subject.date_created).to eq ["09/02/2015"]
    end
  end

  describe "#pending_uploads" do
    it "finds all pending uploads" do
      pending_upload = FactoryGirl.create(:pending_upload, curation_concern_id: solr_document.id)
      expect(subject.pending_uploads).to eq [pending_upload]
    end
  end

  describe "#logical_order_object" do
    before do
      allow(solr_document).to receive(:logical_order).and_return("nodes": [{ label: "Chapter 1", proxy: "test" }])
    end
    it "returns a logical order object" do
      expect(subject.logical_order_object.nodes.length).to eq 1
    end
    it "returns decorated nodes" do
      expect(subject.logical_order_object.nodes.first).to respond_to :proxy_for_object
    end
  end

  describe "attribute_to_html" do
    context "when given an arabic string" do
      let(:title) { "حكاية" }
      it "marks it as rtl" do
        expect(subject.attribute_to_html(:title)).to include "dir=rtl"
      end
    end
    context "when given a bad field" do
      it "logs it" do
        allow(Rails.logger).to receive(:warn)

        expect(subject.attribute_to_html(:bad_field)).to eq nil

        expect(Rails.logger).to have_received :warn
      end
    end
  end

  describe "export linked data", vcr: { cassette_name: 'bibdata-jsonld' } do
    let(:resource) { FactoryGirl.create(:scanned_resource_in_collection, source_metadata_identifier: '2028405') }
    let(:collection) { resource.member_of_collections.first }
    subject { described_class.new(SolrDocument.new(resource.to_solr), ability) }

    context "when the resource has remote metadata" do
      before do
        resource.apply_remote_metadata
      end

      it 'Merges remote JSON-LD with local values' do
        json = JSON.parse(subject.export_as_jsonld)

        expect(json['edm_rights']).to eq ['http://rightsstatements.org/vocab/NKC/1.0/']
        expect(json['title']).to eq({ '@value': 'The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two', '@language': 'eng' }.stringify_keys)
        expect(json['description']).to eq 'Seal of the Library of Congress on t.p.'
        expect(json['format']).to eq 'Book'
        expect(json['date']).to eq '1952'
        expect(json['memberOf']).to eq [{ '@id': "http://plum.com/collections/#{collection.id}", 'title': collection.title.first }.stringify_keys]
      end
    end

    context "when the resource has only local metadata" do
      it 'displays the local values' do
        json = JSON.parse(subject.export_as_jsonld)
        expect(json['edm_rights']).to eq ['http://rightsstatements.org/vocab/NKC/1.0/']
        expect(json['title']).to eq('Test title')
      end

      it 'generates turtle' do
        ttl = subject.export_as_ttl
        expect(ttl).to include '<http://purl.org/dc/terms/title> "Test title"'
        expect(ttl).to include '<http://www.europeana.eu/schemas/edm/rights> "http://rightsstatements.org/vocab/NKC/1.0/"'
      end

      it 'generates ntriples' do
        nt = subject.export_as_nt
        expect(nt).to include '<http://purl.org/dc/terms/title> "Test title"'
        expect(nt).to include '<http://www.europeana.eu/schemas/edm/rights> "http://rightsstatements.org/vocab/NKC/1.0/"'
      end
    end
  end
end
