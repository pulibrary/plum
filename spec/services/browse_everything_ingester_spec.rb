# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BrowseEverythingIngester do
  subject { described_class.new(curation_concern, upload_set_id, actor, file_info) }
  let(:curation_concern) { FactoryGirl.create(:scanned_resource) }
  let(:upload_set_id) { "2" }
  let(:actor) do
    FileSetActor.new(FileSet.new, current_user)
  end
  let(:current_user) { FactoryGirl.create(:user) }
  let(:file) { File.open(Rails.root.join("spec", "fixtures", "files", "color.tif")) }
  let(:file_info) do
    {
      "url" => "file://#{file.path}",
      "file_name" => File.basename(file.path),
      "file_size" => file.size
    }
  end

  describe "#save" do
    let(:download_path) { Rails.root.join("tmp", "spec", "downloaded.tif") }
    before do
      FileUtils.mkdir_p(download_path.dirname)
      FileUtils.cp(file.path, download_path)
      allow(CharacterizeJob).to receive(:perform_later).once
      expect(File.exist?(download_path)).to eq true
      allow_any_instance_of(BrowseEverything::Retriever).to receive(:download).and_return(download_path)
    end
    it "cleans up the downloaded file" do
      subject.save

      expect(File.exist?(download_path)).to eq false
    end
  end
end
