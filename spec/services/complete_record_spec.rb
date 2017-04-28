require 'rails_helper'

RSpec.describe CompleteRecord do
  subject { described_class.new(obj) }
  let(:ark) { 'ark:88435/x1234567' }
  let(:minter) { double('Ezid::Identifier') }
  let(:base_metadata) {{
    dc_publisher: 'Princeton University Library',
    dc_title: 'Test title',
    dc_type: 'Text'
  }}

  before do
    allow(subject).to receive(:minter).and_return(minter)
    allow(subject).to receive(:minter_user).and_return('pudiglib')
  end

  describe "metadata" do
    context "with a bibdata source_metadata_identifier" do
      let(:bib) { '1234567' }
      let(:metadata) { base_metadata.merge(target: "https://pulsearch.princeton.edu/catalog/#{bib}#view") }
      let(:obj) { FactoryGirl.build :scanned_resource, source_metadata_identifier: [bib], identifier: [ark] }
      it "links to OrangeLight" do
        expect(minter).to receive(:modify).with(ark, metadata)
        subject.complete
      end
    end

    context "with a pulfa source_metadata_identifier" do
      let(:cid) { 'AC057/c18' }
      let(:metadata) { base_metadata.merge(target: "http://findingaids.princeton.edu/collections/#{cid}") }
      let(:obj) { FactoryGirl.build :scanned_resource, source_metadata_identifier: [cid], identifier: [ark] }
      it "links to OrangeLight" do
        expect(minter).to receive(:modify).with(ark, metadata)
        subject.complete
      end
    end

    context "without a source_metadata_identifier" do
      let(:metadata) { base_metadata.merge(target: "http://plum.com/concern/scanned_resources/#{obj.id}") }
      let(:obj) { FactoryGirl.create :scanned_resource, id: '1234567', identifier: [ark], source_metadata_identifier: nil }
      it "links to OrangeLight" do
        expect(minter).to receive(:modify).with(ark, metadata)
        subject.complete
      end
    end
  end
end
