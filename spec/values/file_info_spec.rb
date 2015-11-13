require 'rails_helper'

RSpec.describe FileInfo do
  subject { described_class.new(file_info) }
  let(:file_info) do
    {
      "url" => "file:///bla/test/1.tiff",
      "file_name" => "1.tiff",
      "file_size" => 100
    }
  end

  describe "#to_h" do
    it "returns the file info" do
      expect(subject.to_h).to eq file_info
    end
  end

  describe "[]" do
    it "accesses the hash" do
      expect(subject["file_name"]).to eq "1.tiff"
    end
  end

  describe "#has_key?" do
    it "delegates to the hash" do
      expect(subject).to have_key "file_name"
    end
  end

  describe "#file_name" do
    it "returns the file name" do
      expect(subject.file_name).to eq "1.tiff"
    end
  end

  describe "#file_path" do
    it "returns a FilePath of the path" do
      expect(subject.file_path.uri).to eq file_info["url"]
      expect(subject.file_path.clean).to eq "/bla/test/1.tiff"
    end
  end

  describe "#mime_type" do
    it "returns the mime type of the path based on extension" do
      expect(subject.mime_type).to eq "image/tiff"
    end
    context "when the file_info hash provides a mime type" do
      let(:file_info) do
        {
          "url" => "file:///bla/test/1.tiff",
          "file_name" => "1.tiff",
          "file_size" => 100,
          "mime_type" => "image/jpeg"
        }
      end
      it "uses that" do
        expect(subject.mime_type).to eq "image/jpeg"
      end
    end
  end
end
