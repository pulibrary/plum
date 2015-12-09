# Generated via
#  `rails generate worthwhile:work ScannedResource`
require 'rails_helper'

describe ScannedResource do
  let(:scanned_resource) { FactoryGirl.build(:scanned_resource, source_metadata_identifier: '12345', access_policy: 'Policy', use_and_reproduction: 'Statement') }
  let(:reloaded)         { described_class.find(scanned_resource.id) }
  subject { scanned_resource }

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

  describe 'has policy fields' do
    # TODO: Set by policy key and test by value
    [:access_policy, :use_and_reproduction].each do |policy_type|
      it "should let me set a #{policy_type}" do
        policy = 'This is a policy'
        subject.send("#{policy_type}=", policy)
        expect { subject.save }.to_not raise_error
        expect(reloaded.send(policy_type)).to eq policy
      end

      it "should require me to set a #{policy_type}" do
        subject.send("#{policy_type}=", nil)
        expect(subject.valid?).to be_falsey
      end
    end
  end

  describe 'apply_remote_metadata' do
    context 'when source_metadata_identifier is not set' do
      before { subject.source_metadata_identifier = nil }
      it 'does nothing' do
        original_attributes = subject.attributes
        expect(subject.send(:remote_metadata_factory)).to_not receive(:new)
        subject.apply_remote_metadata
        expect(subject.attributes).to eq(original_attributes)
      end
    end
    context 'With a Pulfa ID', vcr: { cassette_name: 'pulfa' } do
      before do
        subject.source_metadata_identifier = 'AC123_c00004'
      end

      # Pending until
      # https://github.com/pulibrary/pul_metadata_services/issues/5 is closed
      xit 'Extracts Pulfa Metadata and full source' do
        subject.apply_remote_metadata
        expect(subject.title.first).to eq('Series 1: University Librarian Records - Subseries 1A, Frederic Vinton - Correspondence')
        expect(subject.creator.first).to eq('Princeton University. Library. Dept. of Rare Books and Special Collections')
        expect(subject.publisher.first).to eq('Princeton University. Library. Dept. of Rare Books and Special Collections')
        expect(subject.date_created.first).to eq('1734-2012')
        expect(subject.source_metadata).to eq(fixture('pulfa-AC123_c00004.xml').read)
      end

      # FIXME: Save currently raises a worthwhile dependency error for
      # Curate::DateFormatter
      it 'Saves a record with extacted ead metadata' do
        subject.apply_remote_metadata
        subject.save
        expect { subject.save }.to_not raise_error
        expect(subject.id).to be_truthy
      end
    end

    context 'With a Voyager ID', vcr: { cassette_name: "bibdata" }do
      before do
        subject.source_metadata_identifier = '2028405'
      end

      it 'Extracts Voyager Metadata' do
        subject.apply_remote_metadata
        expect(subject.title).to eq(['The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.'])
        expect(subject.sort_title).to eq('Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.')
        expect(subject.creator).to eq(['Miner, Dorothy Eugenia.'])
        expect(subject.date_created).to eq(['1952'])
        expect(subject.publisher).to eq(['Fake Publisher'])
        expect(subject.source_metadata).to eq(fixture('voyager-2028405.xml').read)
      end

      it 'Saves a record with extacted Voyager metadata' do
        subject.apply_remote_metadata
        subject.save
        expect { subject.save }.to_not raise_error
        expect(subject.id).to be_truthy
      end
    end
  end

  describe 'gets a noid' do
    it 'that conforms to a valid pattern' do
      expect { subject.save }.to_not raise_error
      noid_service = ActiveFedora::Noid::Service.new
      expect(noid_service.valid? subject.id).to be_truthy
    end
  end

  describe "#viewing_direction" do
    it "maps to the IIIF predicate" do
      expect(described_class.properties["viewing_direction"].predicate).to eq RDF::Vocab::IIIF.viewingDirection
    end
  end

  describe "#viewing_hint" do
    it "maps to the IIIF predicate" do
      expect(described_class.properties["viewing_hint"].predicate).to eq RDF::Vocab::IIIF.viewingHint
    end
  end

  describe "validations" do
    it "validates with the viewing direction validator" do
      expect(subject._validators[nil].map(&:class)).to include ViewingDirectionValidator
    end
    it "validates with the viewing hint validator" do
      expect(subject._validators[nil].map(&:class)).to include ViewingHintValidator
    end
  end

  describe "#state" do
    it "validates with the state validator" do
      expect(subject._validators[nil].map(&:class)).to include StateValidator
    end
    it "accepts a valid state" do
      subject.state = "pending"
      expect(subject.valid?).to eq true
    end
    it "rejects an invalid state" do
      subject.state = "blargh"
      expect(subject.valid?).to eq false
    end
  end

  describe "#check_state" do
    subject { FactoryGirl.build(:scanned_resource, source_metadata_identifier: '12345', access_policy: 'Policy', use_and_reproduction: 'Statement', state: 'final_review') }
    let(:complete_reviewer) { FactoryGirl.create(:complete_reviewer) }
    before do
      complete_reviewer.save
      subject.save
    end
    it "completes record when state changes to 'complete'", vcr: { cassette_name: "ezid" } do
      allow(subject).to receive("state_changed?").and_return true
      subject.state = 'complete'
      expect { subject.check_state }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(subject.identifier).to eq 'ark:/99999/fk4445wg45'
    end
    it "does not complete record when state doesn't change" do
      allow(subject).to receive("state_changed?").and_return false
      subject.state = 'complete'
      expect(subject).not_to receive(:complete_record)
      expect { subject.check_state }.not_to change { ActionMailer::Base.deliveries.count }
    end
    it "does not complete record when state isn't 'complete'" do
      subject.state = 'final_review'
      expect(subject).not_to receive(:complete_record)
      expect { subject.check_state }.not_to change { ActionMailer::Base.deliveries.count }
    end
    it "does not overwrite existing identifier" do
      allow(subject).to receive("state_changed?").and_return true
      subject.state = 'complete'
      subject.identifier = '1234'
      expect(subject).not_to receive("identifier=")
      expect { subject.check_state }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(subject.identifier).to eq('1234')
    end
    it "does not complete the record when the state transition is invalid" do
      allow(subject).to receive("state_changed?").and_return true
      subject.state = 'pending'
      expect(subject).not_to receive(:complete_record)
      expect { subject.check_state }.not_to change { ActionMailer::Base.deliveries.count }
      expect(subject.identifier).to eq(nil)
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
end
