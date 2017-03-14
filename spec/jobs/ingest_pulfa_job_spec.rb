require 'rails_helper'

RSpec::Matchers.define :a_file_named do |x|
  match { |actual| actual.path == x }
end

RSpec.describe IngestPULFAJob do
  describe "ingesting a mets file" do
    let(:mets) { fixture('files/AC057-c18.mets') }
    let(:pdf) { fixture('files/test.pdf') }
    let(:tiff1) { fixture('files/color.tif') }
    let(:tiff2) { fixture('files/gray.tif') }
    let(:jp2_source) { fixture('files/color.jp2') }
    let(:jp3_source) { fixture('files/gray.jp2') }
    let(:jp2_dest) { Rails.root.join('tmp', 'derivatives', 'fi', 'le', 'se', 't2-intermediate_file.jp2') }
    let(:jp3_dest) { Rails.root.join('tmp', 'derivatives', 'fi', 'le', 'se', 't3-intermediate_file.jp2') }
    let(:user) { FactoryGirl.build(:admin) }
    let(:actor1) { double('actor1') }
    let(:actor2) { double('actor2') }
    let(:actor3) { double('actor2') }
    let(:fileset1) { FileSet.new id: 'fileset1' }
    let(:fileset2) { FileSet.new id: 'fileset2' }
    let(:fileset3) { FileSet.new id: 'fileset3' }
    let(:resource) { ScannedResource.new id: 'resource01' }
    let(:existing) { FactoryGirl.create(:scanned_resource, replaces: 'AC057/c18') }

    before do
      existing.update_index
      allow(BatchFileSetActor).to receive(:new).and_return(actor1, actor2, actor3)
      allow(ScannedResource).to receive(:new).and_return(resource)
      allow(FileSet).to receive(:new).and_return(fileset1, fileset2, fileset3)
      allow(FileUtils).to receive(:cp)
      allow(resource).to receive(:save!)
    end

    it "ingests a mets file" do
      expect(actor1).to receive(:attach_related_object).with(resource)
      expect(actor1).to receive(:attach_content).with(a_file_named(pdf.path))
      expect(actor2).to receive(:create_metadata)
      expect(actor2).to receive(:create_content).with(a_file_named(tiff1.path))
      expect(actor2).to receive(:attach_file_to_work).with(resource)
      expect(actor3).to receive(:create_metadata)
      expect(actor3).to receive(:create_content).with(a_file_named(tiff2.path))
      expect(actor3).to receive(:attach_file_to_work).with(resource)
      expect(FileUtils).to receive(:cp).with(jp2_source.path, jp2_dest.to_s)
      expect(FileUtils).to receive(:cp).with(jp3_source.path, jp3_dest.to_s)
      described_class.perform_now(mets, user)
      expect(resource.title.first.to_s).to eq("Henkin, Leon and Tucker, Albert [Transcript no. 19], 1984 May 18")
      expect(resource.visibility).to eq(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)
      expect(fileset2.title.first.to_s).to eq("[1]")
      expect(fileset3.title.first.to_s).to eq("[2]")
      expect { ActiveFedora::Base.find(existing.id) }.to raise_error Ldp::Gone
    end
  end

  describe "error handling" do
    let(:mets) { fixture('files/AC057-c18.mets') }
    let(:user) { FactoryGirl.build(:admin) }

    before do
      allow(ScannedResource).to receive(:new).and_raise(StandardError.new("Test error"))
    end

    it "logs error messages" do
      allow(described_class.logger).to receive(:info).and_call_original
      allow(described_class.logger).to receive(:warn).and_call_original
      expect(described_class.logger).to receive(:info).with("Ingesting PULFA METS #{mets}")
      expect(described_class.logger).to receive(:warn).with("Test error")
      expect { described_class.perform_now(mets, user) }.not_to raise_error
    end
  end
end
