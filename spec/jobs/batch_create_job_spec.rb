# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BatchCreateJob do
  let(:user) { FactoryGirl.create(:user) }

  describe "#perform" do
    subject { described_class.perform_now(user, uploaded_files, metadata) }
    let(:file) { File.open(fixture_path + '/files/9284317.tiff') }
    let(:upload) { Hyrax::UploadedFile.create(user: user, file: file) }
    let(:upload_path) { upload.file.path }
    let(:model) { 'ImageWork' }
    let(:metadata) { { keyword: [], model: model } }

    context 'when an upload_id integer is passed in uploaded_files' do
      let(:uploaded_files) { [upload.id.to_s] }

      it 'spawns an IngestWorkFromFileJob for the work' do
        expect(IngestWorkFromFileJob).to receive(:perform_later).with(user,
                                                                      upload_path,
                                                                      model).and_return(true)
        subject
      end
    end

    context 'when a file path string is passed in uploaded_files' do
      let(:uploaded_files) { [upload_path] }

      it 'spawns an IngestWorkFromFileJob for the work' do
        expect(IngestWorkFromFileJob).to receive(:perform_later).with(user,
                                                                      upload_path,
                                                                      model).and_return(true)
        subject
      end
    end
  end
end
