# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IngestScannedMapsService, :admin_set do
  subject { described_class.new(logger) }
  let(:logger) { Logger.new(nil) }
  let(:map_dir) { Rails.root.join('spec', 'fixtures', 'ingest_scanned_maps') }
  let(:user) { FactoryGirl.create(:admin) }
  let(:resource) { ImageWork.new }
  let(:reloaded) { resource.reload }

  describe '#ingest_dir' do
    context 'with a directory of TIFFs', vcr: { cassette_name: 'bibdata-maps' } do
      before do
        allow(ImageWork).to receive(:new).and_return(resource)
      end
      it 'ingests image as an ImageWork' do
        subject.ingest_dir map_dir, user
        expect(resource.file_sets.length).to eq 1
        expect(resource.ordered_members.to_a.map(&:label)).to eq ['9284317.tif']
      end
    end
  end
end
