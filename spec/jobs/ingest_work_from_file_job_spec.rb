# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IngestWorkFromFileJob do
  let(:user) { FactoryGirl.create(:user) }

  describe "#perform" do
    subject { described_class.perform_now(user, file_path, model) }
    let(:map_ingest_service) { instance_double(IngestScannedMapsService) }
    let(:ingest_service) { instance_double(IngestService) }
    let(:file_path) { '/path/to/upload' }

    context 'when the model is ImageWork' do
      let(:model) { 'ImageWork' }

      before do
        allow(IngestScannedMapsService).to receive(:new).and_return(map_ingest_service)
      end

      it 'ingests the work using IngestScannedMapsService' do
        expect(map_ingest_service).to receive(:ingest_work).with(file_path, user)
        subject
      end
    end

    context 'when the model is not ImageWork' do
      let(:model) { 'ScannedResource' }

      before do
        allow(IngestService).to receive(:new).and_return(ingest_service)
      end

      it 'ingests the work using IngestService' do
        expect(ingest_service).to receive(:ingest_work).with(file_path, user)
        subject
      end
    end
  end
end
