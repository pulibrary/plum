require 'rails_helper'

RSpec.describe IngestMETSJob do
  describe "ingesting a mets file" do
    let(:mets_file) { Rails.root.join("spec", "fixtures", "pudl0001-4612596.mets") }
    let(:mets_file_rtl) { Rails.root.join("spec", "fixtures", "pudl0032-ns73.mets") }
    let(:tiff_file) { Rails.root.join("spec", "fixtures", "files", "color.tif") }
    let(:user) { FactoryGirl.build(:admin) }
    let(:actor) { double('actor') }
    let(:fileset) { double('fileset') }
    let(:resource) { ScannedResource.new }
    let(:file_path) { '/tmp/pudl0001/4612596/00000001.tif' }
    let(:mime_type) { 'image/tiff' }
    let(:file) { IoDecorator.new(tiff_file, mime_type, File.basename(file_path)) }

    before do
      allow(CurationConcerns::FileSetActor).to receive(:new).and_return(actor)
      allow(FileSet).to receive(:new).and_return(fileset)
      allow(ScannedResource).to receive(:new).and_return(resource)
      allow(fileset).to receive(:id).and_return('file1')
      allow_any_instance_of(METSDocument).to receive(:decorated_file).and_return(file)
      allow_any_instance_of(METSDocument).to receive(:thumbnail_path).and_return(file_path)
      allow_any_instance_of(ScannedResource).to receive(:save!)
    end

    it "ingests a mets file", vcr: { cassette_name: 'bibdata-4612596' } do
      expect(actor).to receive(:create_metadata).with(resource, {})
      expect(actor).to receive(:create_content).with(file)
      described_class.perform_now(mets_file, user)
      expect(resource.title).to eq(["Ars minor [fragment]."])
      expect(resource.thumbnail_id).to eq('file1')
      expect(resource.viewing_direction).to eq('left-to-right')
    end

    it "ingests a right-to-left mets file", vcr: { cassette_name: 'bibdata-4790889' } do
      allow(actor).to receive(:create_metadata)
      allow(actor).to receive(:create_content)
      described_class.perform_now(mets_file_rtl, user)
      expect(resource.viewing_direction).to eq('right-to-left')
    end
  end
end