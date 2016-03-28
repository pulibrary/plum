require 'rails_helper'

RSpec.describe ExhibitIdValidator do
  subject { described_class.new }

  describe "#validate" do
    let(:errors) { double("Errors") }
    let(:solr_response) {
      {
        "facet_counts": {
          "facet_fields": {
            "exhibit_id_tesim": ['slug1', 1]
          }.stringify_keys
        }.stringify_keys
      }.stringify_keys
    }
    before do
      expect(ActiveFedora::SolrService).to receive(:get).and_return(solr_response)
      allow(errors).to receive(:add)
    end

    context "when the exhibit id unique" do
      it "does not add errors" do
        record = build_record("slug2")
        subject.validate(record)

        expect(errors).not_to have_received(:add)
      end
    end

    context "when the exhibit id already exists" do
      it "adds errors" do
        record = build_record("slug1")
        subject.validate(record)

        expect(errors).to have_received(:add).with(:exhibit_id, :exclusion, value: "slug1")
      end
    end
  end

  def build_record(exhibit_id)
    record = object_double Collection.new
    allow(record).to receive(:errors).and_return(errors)
    allow(record).to receive(:exhibit_id).and_return(exhibit_id)
    allow(record).to receive(:exhibit_id_changed?).and_return(true)
    allow(record).to receive(:read_attribute_for_validation).with(:exhibit_id).and_return(record.exhibit_id)
    record
  end
end
