# Generated via
#  `rails generate hyrax:work MultiVolumeWork`
require 'rails_helper'

describe MultiVolumeWork do
  let(:nkc) { 'http://rightsstatements.org/vocab/NKC/1.0/' }
  let(:multi_volume_work) { FactoryGirl.build(:multi_volume_work, source_metadata_identifier: '12345', rights_statement: nkc) }
  let(:scanned_resource1) { FactoryGirl.build(:scanned_resource, title: ['Volume 1'], rights_statement: nkc) }
  let(:scanned_resource2) { FactoryGirl.build(:scanned_resource, title: ['Volume 2'], rights_statement: nkc) }
  let(:file_set)          { FactoryGirl.build(:file_set) }
  let(:reloaded)          { described_class.find(multi_volume_work.id) }
  subject { multi_volume_work }

  describe 'has note fields' do
    [:portion_note, :description].each do |note_type|
      it "should let me set a #{note_type}" do
        note = 'This is note text'
        subject.send("#{note_type}=", note)
        expect { subject.save }.to_not raise_error
        expect(reloaded.send(note_type)).to eq note
      end
    end
  end

  describe 'has source metadata id' do
    it 'allows setting of metadata id' do
      id = '12345'
      subject.source_metadata_identifier = id
      expect { subject.save }.to_not raise_error
      expect(reloaded.source_metadata_identifier).to eq id
    end
  end

  context "validating title and metadata id" do
    before do
      subject.source_metadata_identifier = nil
      subject.title = nil
    end
    context "when neither metadata id nor title is set" do
      it 'fails' do
        expect(subject.valid?).to eq false
      end
    end
    context "when only metadata id is set" do
      before do
        subject.source_metadata_identifier = "12355"
      end
      it 'passes' do
        expect(subject.valid?).to eq true
      end
    end
    context "when only title id is set" do
      before do
        subject.title = ["A Title.."]
      end
      it 'passes' do
        expect(subject.valid?).to eq true
      end
    end
  end

  describe 'has scanned resource members' do
    before do
      subject.ordered_members = [scanned_resource1, scanned_resource2]
      scanned_resource1.thumbnail = file_set
    end
    it "has scanned resources" do
      expect(subject.ordered_members).to eq [scanned_resource1, scanned_resource2]
    end
    it "can persist when it has a thumbnail set to scanned resource" do
      subject.thumbnail = scanned_resource1
      expect(subject.save).to eq true
      expect(subject.thumbnail_id).to eq file_set.id
    end
  end

  describe "#pending_uploads" do
    it "returns all pending uploads" do
      subject.save
      pending_upload = FactoryGirl.create(:pending_upload, curation_concern_id: subject.id)

      expect(subject.pending_uploads).to eq [pending_upload]
    end
    it "doesn't return anything for other resources' pending uploads" do
      subject.save
      FactoryGirl.create(:pending_upload, curation_concern_id: "banana")

      expect(subject.pending_uploads).to eq []
    end
    context "when not persisted" do
      it "returns a blank array" do
        expect(described_class.new.pending_uploads).to eq []
      end
    end
  end

  include_examples "structural metadata"
end
