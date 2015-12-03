require 'rails_helper'

describe StateWorkflow do
  subject { described_class.new :pending }

  describe 'ingest workflow' do
    it 'proceeds through ingest workflow' do
      # initial state: pending
      expect(subject.pending?).to be true
      expect(subject.aasm.current_state).to eq :pending
      expect(subject.may_finalize_digitization?).to be true
      expect(subject.may_finalize_metadata?).to be false
      expect(subject.may_complete?).to be false
      expect(subject.may_takedown?).to be false
      expect(subject.may_flag?).to be false
      expect(subject.suppressed?).to be true

      # digitization signoff moves to metadata review
      expect(subject.finalize_digitization).to be true
      expect(subject.metadata_review?).to be true
      expect(subject.aasm.current_state).to eq :metadata_review
      expect(subject.may_finalize_digitization?).to be false
      expect(subject.may_finalize_metadata?).to be true
      expect(subject.may_complete?).to be false
      expect(subject.may_takedown?).to be false
      expect(subject.may_flag?).to be false
      expect(subject.suppressed?).to be true

      # metadata signoff moves to final review
      expect(subject.finalize_metadata).to be true
      expect(subject.final_review?).to be true
      expect(subject.aasm.current_state).to eq :final_review
      expect(subject.may_finalize_digitization?).to be false
      expect(subject.may_finalize_metadata?).to be false
      expect(subject.may_complete?).to be true
      expect(subject.may_takedown?).to be false
      expect(subject.may_flag?).to be false
      expect(subject.suppressed?).to be true

      # final signoff moves to complete
      expect(subject.complete).to be true
      expect(subject.complete?).to be true
      expect(subject.aasm.current_state).to eq :complete
      expect(subject.may_finalize_digitization?).to be false
      expect(subject.may_finalize_metadata?).to be false
      expect(subject.may_complete?).to be false
      expect(subject.may_takedown?).to be true
      expect(subject.may_flag?).to be true
      expect(subject.suppressed?).to be false
    end
  end

  describe 'takedown workflow' do
    subject { described_class.new :complete }
    it 'goes back and forth between complete and takedown' do
      expect(subject.complete?).to be true
      expect(subject.aasm.current_state).to eq :complete
      expect(subject.may_restore?).to be false
      expect(subject.may_takedown?).to be true
      expect(subject.suppressed?).to be false

      expect(subject.takedown).to be true
      expect(subject.takedown?).to be true
      expect(subject.aasm.current_state).to eq :takedown
      expect(subject.may_restore?).to be true
      expect(subject.may_takedown?).to be false
      expect(subject.suppressed?).to be true

      expect(subject.restore).to be true
      expect(subject.complete?).to be true
      expect(subject.aasm.current_state).to eq :complete
      expect(subject.may_restore?).to be false
      expect(subject.may_takedown?).to be true
      expect(subject.suppressed?).to be false
    end
  end

  describe 'flagging workflow' do
    subject { described_class.new :complete }
    it 'goes back and forth between flagged and unflagged' do
      expect(subject.complete?).to be true
      expect(subject.aasm.current_state).to eq :complete
      expect(subject.may_flag?).to be true
      expect(subject.may_unflag?).to be false
      expect(subject.suppressed?).to be false

      expect(subject.flag).to be true
      expect(subject.aasm.current_state).to eq :flagged
      expect(subject.may_flag?).to be false
      expect(subject.may_unflag?).to be true
      expect(subject.suppressed?).to be false

      expect(subject.unflag).to be true
      expect(subject.aasm.current_state).to eq :complete
      expect(subject.may_flag?).to be true
      expect(subject.may_unflag?).to be false
      expect(subject.suppressed?).to be false
    end
  end

  describe 'persistence' do
    states = [:pending, :metadata_review, :final_review, :complete, :flagged, :takedown]
    it 'loads from state property' do
      states.each do |state|
        state_machine = described_class.new state
        expect(state_machine.send "#{state}?").to be true
      end
    end
  end
end
