require 'rails_helper'

RSpec.describe Vocabulary, type: :model do
  subject { FactoryGirl.build :vocabulary }
  let(:parent) { FactoryGirl.build(:vocabulary, label: 'Parent Vocabulary') }

  it 'has a label' do
    expect(subject.label).to eq('LAE Subjects')
    subject.label = 'Updated Label'
    expect(subject.label).to eq('Updated Label')
  end

  it 'has a parent' do
    expect(subject.parent).to be nil
    subject.parent = parent
    expect(subject.parent).to eq(parent)
  end
end
