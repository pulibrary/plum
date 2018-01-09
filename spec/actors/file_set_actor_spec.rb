# frozen_string_literal: true
require 'rails_helper'

describe FileSetActor do
  subject { actor }
  let(:user) { FactoryGirl.create(:user) }
  let(:scanned_resource) { FactoryGirl.build(:scanned_resource, id: 'id') }
  let(:vector_work) { FactoryGirl.build(:vector_work, id: 'id') }
  let(:file_set) { FactoryGirl.build(:file_set) }
  let(:messenger) { double }
  let(:actor) do
    described_class.new(file_set, user)
  end
  before do
    allow(ManifestEventGenerator).to receive(:new).and_return(messenger)
  end

  describe '#attach_file_to_work' do
    context 'when the parent work is a ScannedResource' do
      it 'fires a record_updated manifest event' do
        expect(messenger).to receive(:record_updated)
        subject.attach_file_to_work(scanned_resource, {})
      end
    end

    context 'when the parent work is a VectorWork' do
      it 'does not fire a record_updated manifest event' do
        expect(messenger).not_to receive(:record_updated)
        subject.attach_file_to_work(vector_work, {})
      end
    end
  end
end
