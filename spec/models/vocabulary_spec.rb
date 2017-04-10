require 'rails_helper'

RSpec.describe Vocabulary, type: :model do
  subject { FactoryGirl.build :vocabulary }

  it 'has a label' do
    expect(subject.label).to eq('LAE Subjects')
    subject.label = 'Updated Label'
    expect(subject.label).to eq('Updated Label')
  end
end
