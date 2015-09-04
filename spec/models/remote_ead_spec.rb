require 'rails_helper'

RSpec.describe RemoteEad, vcr: { cassette_name: 'pulfa' } do
  subject { described_class.new(ead_id) }
  let(:ead_id) { "AC123_c00004" }

  describe "#title" do
    it "finds the title" do
      expect(subject.title).to eq ['Series 1: University Librarian Records - Subseries 1A, Frederic Vinton - Correspondence']
    end
  end

  describe "#creator" do
    it "finds the creator" do
      expect(subject.creator).to eq ['Princeton University. Library. Dept. of Rare Books and Special Collections']
    end
  end

  describe "#publisher" do
    it "finds the publisher" do
      expect(subject.publisher).to eq ['Princeton University. Library. Dept. of Rare Books and Special Collections']
    end
  end

  describe "#date_created" do
    it "finds the date created" do
      expect(subject.date_created).to eq ['1734-2012']
    end
  end

  describe "#attributes" do
    it "returns all attributes" do
      expect(subject.attributes).to eq(
        title: subject.title,
        creator: subject.creator,
        publisher: subject.publisher,
        date_created: subject.date_created
      )
    end
  end
end
