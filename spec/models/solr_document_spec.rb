require 'rails_helper'

RSpec.describe SolrDocument do
  subject { described_class.new(document_hash) }

  let(:date_created) { "2015-09-02" }
  let(:document_hash) do
    {
      date_created_tesim: date_created,
      language_tesim: ['eng']
    }
  end

  describe "#date_created" do
    it "returns date_created_tesim" do
      expect(subject.date_created).to eq date_created
    end
  end

  describe "#logical_order" do
    it "is an empty hash by default" do
      expect(subject.logical_order).to eq({})
    end
  end

  describe '#ocr_langage' do
    it 'defaults to language if not present' do
      expect(subject['ocr_language_tesim']).to be nil
      expect(subject.language).to eq(['eng'])
      expect(subject.ocr_language).to eq(['eng'])
    end
  end
end
