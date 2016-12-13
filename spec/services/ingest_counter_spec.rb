require 'rails_helper'

RSpec.describe IngestCounter do
  subject { described_class.new(2) }

  describe '#increment' do
    it 'counts' do
      expect(subject.increment).to eq(1)
    end

    it 'pauses http when limit is reached and resets count' do
      expect_any_instance_of(Net::HTTP::Persistent).to receive(:shutdown)
      expect(subject.increment).to eq(1)
      expect(subject.increment).to eq(0)
    end
  end
end
