require 'rails_helper'

RSpec.describe RemoteBibdata, vcr: { cassette_name: "bibdata" } do
  subject { described_class.new(bibdata_uri) }
  let(:bibdata_uri) { "2028405" }

  describe "#title" do
    it "finds the title" do
      expect(subject.title).to eq ['The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.']
    end
  end

  describe "#creator" do
    it "finds creators" do
      expect(subject.creator).to eq ['Miner, Dorothy Eugenia.']
    end
  end

  describe "#date_created" do
    it "finds date_created" do
      expect(subject.date_created).to eq ['1952']
    end
  end

  describe "#publisher" do
    it "finds publisher" do
      expect(subject.publisher).to eq ['Fake Publisher']
    end
  end

  describe "#attributes" do
    it "returns an attributes hash" do
      expect(subject.attributes).to eq(
        title: subject.title,
        creator: subject.creator,
        date_created: subject.date_created,
        publisher: subject.publisher
      )
    end
  end
end
