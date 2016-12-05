require 'rails_helper'

RSpec.describe ValidateIngestJob do
  let(:mets_file) { Rails.root.join('spec', 'fixtures', 'pudl0001-4612596.mets') }
  let(:file_set) { FactoryGirl.build :file_set }
  let(:file_set_id) { 'abcdefghij' }
  let(:checksum) { '5b0ed4a62f96a19c5267fa8a9e1caf876c87e8d0' }
  let(:replaces) { 'pudl0001/4612596/00000001' }
  let(:original_file) { double('original_file') }
  let(:checksum_stub) { double('checksum_stub') }
  let(:logger) { double('logger_stub') }

  before do
    allow_any_instance_of(described_class).to receive(:logger).and_return(logger)
    allow(logger).to receive(:info)
  end

  describe 'validates the checksum of a fileset' do
    before do
      allow(file_set).to receive(:id).and_return(file_set_id)
      allow(file_set).to receive(:original_file).and_return(original_file)
      allow(original_file).to receive(:checksum).and_return(checksum_stub)
    end

    describe 'a valid checksum' do
      it 'does not generate any errors' do
        allow(FileSet).to receive(:where).and_return([file_set])
        expect(logger).not_to receive(:error)
        expect(logger).not_to receive(:warn)
        described_class.perform_now(mets_file)
      end
    end

    describe 'a checksum that matches the file on disk, but not the METS checksum' do
      it 'generates a warning' do
        allow(FileSet).to receive(:where).and_return([], [file_set])
        allow(Digest::SHA1).to receive(:hexdigest).and_return('5b0ed4a62f96a19c5267fa8a9e1caf876c87e8d0')
        allow(File).to receive(:read)
        expect(logger).to receive(:warn).with("#{replaces} => #{file_set_id} (matches checksum from disk)")
        described_class.perform_now(mets_file)
      end
    end

    describe 'an invalid checksum' do
      it 'generates a error' do
        allow(FileSet).to receive(:where).and_return([])
        allow(Digest::SHA1).to receive(:hexdigest).and_return('file_sha')
        allow(File).to receive(:read)
        expect(logger).to receive(:error).with("#{replaces}: no FileSet found matching checksum from METS or disk")
        described_class.perform_now(mets_file)
      end
    end
  end
end
