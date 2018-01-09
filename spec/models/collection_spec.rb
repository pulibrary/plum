# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Collection do
  subject { described_class.new title: ['Exhibit 1'], exhibit_id: 'foo' }

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

      result = described_class.create exhibit_id: 'foo'
      expect(result.valid?).to be false
    end

    it "can be saved twice" do
      subject.apply_depositor_metadata 'bar'
      subject.save!
      subject.save!
    end

    it "must not be nil" do
      subject.exhibit_id = nil
      expect(subject.valid?).to be false
    end
  end

  describe "title sort field" do
    it "indexes sort field" do
      expect(subject.to_solr['title_ssort']).to eq 'Exhibit 1'
    end
  end
end
