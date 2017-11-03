require 'rails_helper'

RSpec.describe ExtraLockable do
  let(:work) { FactoryGirl.build(:scanned_resource) }
  let(:work_id) { work.source_metadata_identifier }
  let(:lock_info) { nil }

  around { |example|
    # Ensure there are no existing locks before and after.
    expect(work.lock?(work_id)).to eq false
    example.run
    work.unlock(lock_info) if work.lock?(work_id)
  }

  describe 'lock_id_attribute' do
    it 'is id by default' do
      expect(work.class.lock_id_attribute).to eq :id
    end
  end

  describe '#lock_id' do
    context 'when a valid id is present' do
      before { work.class.lock_id_attribute = :source_metadata_identifier }
      after { work.class.lock_id_attribute = :id }
      it 'returns a string' do
        expect(work.lock_id).to eq "lock_1234567"
      end
    end
    context 'when no valid id is present' do
      it 'raises' do
        expect(work.id.blank?).to eq true # Because work is not persisted in this spec
        expect { work.lock_id }.to raise_error(ArgumentError)
      end
    end
  end

  context 'with no existing lock' do
    describe '#lock' do
      it 'creates a lock' do
        lock_info = work.lock(work_id)
        expect(lock_info).to be_a(Hash)
        expect(work.lock?(work_id)).to eq true
        work.unlock(lock_info)
      end
      it 'creates a lock and self unlocks when given a block' do
        lock_info = work.lock(work_id) { nil }
        expect(lock_info).to eq true
        expect(work.lock?(work_id)).to eq false
      end
      it 'passes options to the lock backend' do
        lock_info = work.lock(work_id, ttl: 12_345)
        lock_info = work.lock(work_id, ttl: 23_456, extend: lock_info)
        expect(lock_info[:validity]).to be > 12_500
        expect(work.lock?(work_id)).to eq true
        work.unlock(lock_info)
      end
    end
    describe '#lock?' do
      it 'detects no existing lock' do
        expect(work.lock?(work_id)).to eq false
      end
    end
  end

  context 'with an existing lock' do
    around { |example|
      lock_info = work.lock_manager.client.lock(work_id, 10_000)
      example.run
      work.lock_manager.client.unlock(lock_info)
    }

    describe '#lock?' do
      it 'detects an existing lock' do
        expect(work.lock?(work_id)).to eq true
      end
    end
  end
end
