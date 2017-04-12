require 'rails_helper'

RSpec.describe IngestService, :admin_set do
  subject { described_class.new(logger) }
  let(:logger) { Logger.new(nil) }
  let(:single_dir) { Rails.root.join('spec', 'fixtures', 'ingest_single') }
  let(:multi_dir) { Rails.root.join('spec', 'fixtures', 'ingest_multi') }
  let(:user) { FactoryGirl.create(:admin) }
  let(:bib) { '4609321' }
  let(:resource1) { ScannedResource.new }
  let(:resource2) { ScannedResource.new }
  let(:multivol) { MultiVolumeWork.new }
  let(:reloaded) { resource.reload }

  describe '#ingest_dir' do
    context 'with a directory of TIFFs', vcr: { cassette_name: 'bibdata-4609321' } do
      before do
        allow(ScannedResource).to receive(:new).and_return(resource1)
      end
      it 'ingests them as a ScannedResource' do
        subject.ingest_dir single_dir, bib, user
        expect(resource1.file_sets.length).to eq 2
        expect(resource1.ordered_members.to_a.map(&:label)).to eq ['color.tif', 'gray.tif']
      end
    end

    context 'with a directory of subdirectories of TIFFs', vcr: { cassette_name: 'bibdata-4609321' } do
      before do
        allow(MultiVolumeWork).to receive(:new).and_return(multivol)
        allow(ScannedResource).to receive(:new).and_return(resource1, resource2)
      end
      it 'ingests them as a MultiVolumeWork' do
        subject.ingest_dir multi_dir, bib, user
        expect(multivol.ordered_members.to_a.length).to eq 2
        expect(multivol.ordered_members).to eq [resource1, resource2]
      end
    end
  end
end
