require 'rails_helper'

RSpec.describe Collection do
  subject { described_class.new title: 'Exhibit 1', exhibit_id: 'foo' }

  describe "#exhibit_id" do
    it "has an exhbit id" do
      expect(subject.exhibit_id).to eq 'foo'
    end

    it "indexes the exhibit id" do
      expect(subject.to_solr['exhibit_id_tesim']).to eq ['foo']
    end

    it "must be unique" do
      subject.apply_depositor_metadata 'bar'
      subject.save!

      described_class.create exhibit_id: 'foo'
      expect(subject.valid?).to be false
    end

    it "must not be nil" do
      subject.exhibit_id = nil
      expect(subject.valid?).to be false
    end
  end
end
