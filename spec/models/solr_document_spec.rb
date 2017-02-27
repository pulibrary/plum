require 'rails_helper'

RSpec.describe SolrDocument do
  subject { described_class.new(document_hash) }

  let(:date_created) { "2015-09-02" }
  let(:date_modified) { "2015-10-01T12:34:56Z" }
  let(:document_hash) do
    {
      date_created_tesim: date_created,
      system_modified_dtsi: date_modified,
      language_tesim: ['eng'],
      width_is: 200,
      height_is: 400
    }
  end

  describe "#date_created" do
    it "returns date_created_tesim" do
      expect(subject.date_created).to eq date_created
    end
  end

  describe "#system_modified" do
    it "has a system modification date" do
      expect(subject.system_modified).to eq('10/01/15 12:34:56 PM UTC')
    end
  end

  describe "#height" do
    it "returns the height_is" do
      expect(subject.height).to eq 400
    end
  end

  describe "#width" do
    it "returns the width_is" do
      expect(subject.width).to eq 200
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

  describe '#method_missing' do
    it 'passes through to super' do
      expect { subject.send :foo }.to raise_error NoMethodError, /undefined method/
    end
  end
end
