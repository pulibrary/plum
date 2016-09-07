require 'rails_helper'

describe IuMetadata::Client do

  let(:fixture_path) { File.expand_path('../../fixtures', __FILE__) }
  let(:marc) { File.open(File.join(fixture_path, 'marc_VAD5427.xml')).read.strip }
  let(:mods) { File.open(File.join(fixture_path, 'mods_VAD5427.xml')).read.strip }

  context 'with an IUCAT id' do
    it 'makes MARC requests to IUCAT', vcr: {cassette_name: 'marc_VAD5427'} do
      expect(described_class.retrieve('VAD5427', :marc).source).to eq marc
    end
    it 'makes MODS requests to IUCAT', vcr: {cassette_name: 'mods_VAD5427'} do
      expect(described_class.retrieve('VAD5427', :mods).source).to eq mods
    end
    it 'returns an empty obj when a record is not found', vcr: {cassette_name: 'mods_deadbeef'} do
      expect(described_class.retrieve('missingrecorddeadbeef', :mods).source.blank?).to be true
    end
    it 'raises errors when an invalid format is specified' do
      expect{described_class.retrieve('VAD5427', :unknownformat).source}.to raise_error
    end
    it 'validates identifiers' do
      expect(described_class.bibdata?('abc123')).to be true
      expect(described_class.bibdata?('abc&123')).to be false
      expect{described_class.retrieve('abc&123', :marc).source}.to raise_error
    end
  end
  # context 'with a Pulfa-like id' do
  #   it 'makes requests to PULFA' do
  #     expect(described_class.retrieve('AC044_c0003').source).to eq ead
  #   end
  # end
end
