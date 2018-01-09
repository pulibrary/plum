# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BrowseEverythingIngestJob do
  let(:user) { FactoryGirl.create(:user) }

  describe "#perform" do
    let(:file1) { fixture_path + "/files/color.tif" }
    let(:file2) { fixture_path + "/files/gray.tif" }
    let(:file_info1) { { 'url' => file1, 'mime_type' => 'image/tiff', 'file_name' => 'color.tif', 'file_size' => '196882' } }
    let(:file_info2) { { 'url' => file2, 'mime_type' => 'image/tiff', 'file_name' => 'gray.tif', 'file_size' => '51610' } }
    let(:object) { FactoryGirl.create :scanned_resource }
    let(:upload_set_id) { 'upload1' }

    before do
      allow_any_instance_of(BrowseEverythingIngester).to receive(:cleanup_download)
      allow_any_instance_of(BrowseEverythingIngester).to receive(:downloaded_file_path).and_return(file1, file2)
      [file1, file2].each do |f|
        PendingUpload.create! curation_concern_id: object.id, file_path: f, upload_set_id: upload_set_id, file_name: f
      end
    end

    it 'does not overwrite ordered_members when run twice' do
      described_class.perform_now object.id, 'upload1', user, '1' => file_info1
      expect(object.reload.ordered_members.to_a.size).to eq(1)

      described_class.perform_now object.id, 'upload1', user, '1' => file_info2
      expect(object.reload.ordered_members.to_a.size).to eq(2)
    end
  end
end
