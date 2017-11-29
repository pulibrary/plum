# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IngestService, :admin_set do
  subject { described_class.new(logger) }
  let(:logger) { Logger.new(nil) }
  let(:single_dir) { Rails.root.join('spec', 'fixtures', 'ingest_single') }
  let(:multi_dir) { Rails.root.join('spec', 'fixtures', 'ingest_multi') }
  let(:user) { FactoryGirl.create(:admin) }
  let(:bib) { '4609321' }
  let(:local_id) { 'cico:xyz' }
  let(:replaces) { 'pudl0001/4609321/331' }
  let(:resource1) { ScannedResource.new }
  let(:resource2) { ScannedResource.new }
  let(:multivol) { MultiVolumeWork.new }
  let(:reloaded) { resource.reload }
  let(:coll) { FactoryGirl.create(:collection) }

  describe '#ingest_dir' do
    context 'with a directory of TIFFs', vcr: { cassette_name: 'bibdata-4609321' } do
      before do
        allow(ScannedResource).to receive(:new).and_return(resource1)
      end
      it 'ingests them as a ScannedResource' do
        subject.ingest_dir single_dir, bib, user, collection: coll, local_id: local_id, replaces: replaces
        expect(resource1.file_sets.length).to eq 2
        expect(resource1.ordered_members.to_a.map(&:label)).to eq ['color.tif', 'gray.tif']
        expect(resource1.member_of_collection_ids).to eq [coll.id]
        expect(resource1.local_identifier).to eq [local_id]
        expect(resource1.replaces).to eq [replaces]
      end
    end

    context 'with a directory of subdirectories of TIFFs', vcr: { cassette_name: 'bibdata-4609321' } do
      before do
        allow(MultiVolumeWork).to receive(:new).and_return(multivol)
        allow(ScannedResource).to receive(:new).and_return(resource1, resource2)
      end
      it 'ingests them as a MultiVolumeWork' do
        subject.ingest_dir multi_dir, bib, user, {}
        expect(multivol.ordered_members.to_a.length).to eq 2
        expect(multivol.ordered_members).to eq [resource1, resource2]
      end
    end
  end

  describe '#attach_dir' do
    context 'with a set of LAE images' do
      let(:barcode1) { '32101075851400' }
      let(:barcode2) { '32101075851418' }
      let(:lae_dir) { Rails.root.join('spec', 'fixtures', 'lae') }
      before do
        @folder1 = FactoryGirl.create(:ephemera_folder, barcode: [barcode1])
        @folder2 = FactoryGirl.create(:ephemera_folder, barcode: [barcode2])
      end

      it 'attaches the files' do
        subject.attach_each_dir(lae_dir, 'barcode_ssim', user, '.tif')
        expect(@folder1.reload.members.size).to eq(1)
        expect(@folder2.reload.members.size).to eq(2)
      end
    end
  end
end
