require 'rails_helper'

RSpec.describe IngestMETSJob do
  describe "ingesting a mets file" do
    let(:mets_file) { Rails.root.join("spec", "fixtures", "pudl0001-4612596.mets") }
    let(:tiff_file) { Rails.root.join("spec", "fixtures", "files", "color.tif") }
    let(:user) { FactoryGirl.build(:admin) }
    let(:actor) { double('actor') }
    let(:resource) { ScannedResource.new }
    let(:file_path) { '/tmp/pudl0001/4612596/00000001.tif' }
    let(:mime_type) { 'image/tiff' }
    let(:file) { IoDecorator.new(tiff_file, mime_type, File.basename(file_path)) }

    before do
      allow(CurationConcerns::FileSetActor).to receive(:new).and_return(actor)
      allow(ScannedResource).to receive(:new).and_return(resource)
      allow_any_instance_of(described_class).to receive(:decorated_file).and_return(file)
    end

    it "ingests a mets file", vcr: { cassette_name: 'bibdata-4612596' } do
      expect(actor).to receive(:create_metadata).with(resource, {})
      expect(actor).to receive(:create_content).with(file)
      described_class.perform_now(mets_file, user)
      expect(resource.title).to eq(["Ars minor [fragment]."])
    end
  end
end
