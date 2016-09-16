require 'rails_helper'

RSpec.describe IngestMETSJob do
  describe "ingesting a mets file" do
    let(:mets_file) { Rails.root.join("spec", "fixtures", "pudl0001-4612596.mets") }
    let(:mets_file_rtl) { Rails.root.join("spec", "fixtures", "pudl0032-ns73.mets") }
    let(:mets_file_multi) { Rails.root.join("spec", "fixtures", "pudl0001-4609321-s42.mets") }
    let(:tiff_file) { Rails.root.join("spec", "fixtures", "files", "color.tif") }
    let(:user) { FactoryGirl.build(:admin) }
    let(:actor1) { double('actor1') }
    let(:actor2) { double('actor2') }
    let(:fileset) { FileSet.new }
    let(:work) { MultiVolumeWork.new }
    let(:resource1) { ScannedResource.new id: 'resource1' }
    let(:resource2) { ScannedResource.new id: 'resource2' }
    let(:file_path) { '/tmp/pudl0001/4612596/00000001.tif' }
    let(:mime_type) { 'image/tiff' }
    let(:file) { IoDecorator.new(tiff_file, mime_type, File.basename(file_path)) }
    let(:logical_order) { double('logical_order') }
    let(:order_object) { double('order_object') }

    before do
      allow(FileSetActor).to receive(:new).and_return(actor1, actor2)
      allow(FileSet).to receive(:new).and_return(fileset)
      allow(MultiVolumeWork).to receive(:new).and_return(work)
      allow(ScannedResource).to receive(:new).and_return(resource1, resource2)
      allow(fileset).to receive(:id).and_return('file1')
      allow(fileset).to receive(:title=)
      allow(fileset).to receive(:replaces=)
      allow_any_instance_of(METSDocument).to receive(:decorated_file).and_return(file)
      allow_any_instance_of(METSDocument).to receive(:thumbnail_path).and_return(file_path)
      allow_any_instance_of(METSDocument).to receive(:source_file).and_return(mets_file)
      allow_any_instance_of(ScannedResource).to receive(:save!)
    end

    it "ingests a mets file", vcr: { cassette_name: 'bibdata-4612596' } do
      expect(actor1).to receive(:attach_related_object).with(resource1)
      expect(actor1).to receive(:attach_content).with(instance_of(File))
      expect(actor2).to receive(:create_metadata).with(resource1, {})
      expect(actor2).to receive(:create_content).with(file)
      described_class.perform_now(mets_file, user)
      expect(resource1.title).to eq(["Ars minor [fragment]."])
      expect(resource1.thumbnail_id).to eq('file1')
      expect(resource1.viewing_direction).to eq('left-to-right')
      expect(resource1.state).to eq('final_review')
      expect(resource1.visibility).to eq(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)
    end

    it "ingests a right-to-left mets file", vcr: { cassette_name: 'bibdata-4790889' } do
      allow(actor1).to receive(:attach_related_object)
      allow(actor1).to receive(:attach_content)
      allow(actor2).to receive(:create_metadata)
      allow(actor2).to receive(:create_content)
      described_class.perform_now(mets_file_rtl, user)
      expect(resource1.viewing_direction).to eq('right-to-left')
    end

    it "ingests a multi-volume mets file", vcr: { cassette_name: 'bibdata-4609321' } do
      allow(actor1).to receive(:attach_related_object)
      allow(actor1).to receive(:attach_content)
      allow(actor2).to receive(:create_metadata)
      allow(actor2).to receive(:create_content)
      expect(resource1).to receive(:logical_order).at_least(:once).and_return(logical_order)
      expect(resource2).to receive(:logical_order).at_least(:once).and_return(logical_order)
      expect(logical_order).to receive(:order=).at_least(:once)
      allow(logical_order).to receive(:order).and_return(nil)
      allow(logical_order).to receive(:object).and_return(order_object)
      allow(order_object).to receive(:each_section).and_return([])
      described_class.perform_now(mets_file_multi, user)
      expect(work.ordered_member_ids).to eq(['resource1', 'resource2'])
    end
  end

  describe "integration test" do
    let(:user) { FactoryGirl.build(:admin) }
    let(:mets_file) { Rails.root.join("spec", "fixtures", "pudl0001-4612596.mets") }
    let(:tiff_file) { Rails.root.join("spec", "fixtures", "files", "color.tif") }
    let(:mime_type) { 'image/tiff' }
    let(:file) { IoDecorator.new(File.new(tiff_file), mime_type, File.basename(tiff_file)) }
    let(:resource) { ScannedResource.new }
    let(:fileset1) { FileSet.new }
    let(:fileset2) { FileSet.new }
    let(:order) { {
      nodes: [{
        label: 'leaf 1', nodes: [{
          label: 'leaf 1. recto', proxy: fileset2.id
        }]
      }]
    }}

    before do
      allow_any_instance_of(METSDocument).to receive(:decorated_file).and_return(file)
      allow(ScannedResource).to receive(:new).and_return(resource)
      allow(FileSet).to receive(:new).and_return(fileset1, fileset2)

      allow(IngestFileJob).to receive(:perform_later).and_return(true)
      allow(CharacterizeJob).to receive(:perform_later).and_return(true)
    end

    it "ingests a mets file", vcr: { cassette_name: 'bibdata-4612596' } do
      described_class.perform_now(mets_file, user)
      expect(resource.persisted?).to be true
      expect(resource.file_sets.length).to eq 1
      expect(resource.reload.logical_order.order).to eq(order.deep_stringify_keys)
      expect(fileset2.reload.title).to eq(['leaf 1. recto'])
      expect(resource.member_of_collections.first.title).to eq(['Scheide Library : Fifteenth-Century Printing'])
      expect(resource.replaces).to eq('pudl0001/4612596')
      expect(fileset2.replaces).to eq('pudl0001/4612596/00000001')

      expect(resource.related_objects).to eq([fileset1])
      expect(fileset1.title).to eq(['METS XML'])
      expect(fileset1.files.first.content).to start_with("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n<mets:mets")
    end
  end
end
