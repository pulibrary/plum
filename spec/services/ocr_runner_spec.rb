require 'rails_helper'

RSpec.describe OCRRunner do
  let(:file_set) { FactoryGirl.build(:file_set) }
  subject { described_class.new(file_set) }

  before do
    allow(file_set).to receive(:generic_works).and_return([parent])
    allow(Tesseract).to receive(:languages).and_return(eng: ["English"], ita: ["Italian"], spa: ["Spanish"])
  end

  describe "#language" do
    context "when ocr_language is set" do
      let(:parent) { FactoryGirl.build(:scanned_resource, language: ['spa'], ocr_language: ['ita']) }
      it "uses ocr_language when it is set" do
        expect(subject.send(:language)).to eq('ita')
      end
    end

    context "when ocr_language is not set" do
      let(:parent) { FactoryGirl.build(:scanned_resource, language: ['spa']) }
      it "uses language when ocr_language is not set" do
        expect(subject.send(:language)).to eq('spa')
      end
    end

    context "when neither language nor ocr_language is set" do
      let(:parent) { FactoryGirl.build(:scanned_resource) }
      it "defaults to english" do
        expect(subject.send(:language)).to eq('eng')
      end
    end

    context "when ocr_language is an unsupported language" do
      let(:parent) { FactoryGirl.build(:scanned_resource, ocr_language: ['xxx']) }
      it "defaults to english" do
        expect(subject.send(:language)).to eq('eng')
      end
    end

    context "when ocr_language is an unsupported language, but language is supported" do
      let(:parent) { FactoryGirl.build(:scanned_resource, language: ['spa'], ocr_language: ['xxx']) }
      it "uses the supported language value" do
        expect(subject.send(:language)).to eq('spa')
      end
    end
  end
end
