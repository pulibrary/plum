# frozen_string_literal: true
require 'rails_helper'

RSpec.describe VocabularyTerm, type: :model do
  subject { FactoryGirl.build :vocabulary_term }
  let(:vocab) { FactoryGirl.build :vocabulary, label: 'New Subjects' }

  it 'has a label' do
    expect(subject.label).to start_with('Literacy')
    subject.label = 'Updated Label'
    expect(subject.label).to eq('Updated Label')
  end

  it 'has a vocabulary' do
    expect(subject.vocabulary).to be_a Vocabulary
    expect(subject.vocabulary.label).to start_with('LAE Subjects')
    subject.vocabulary = vocab
    expect(subject.vocabulary).to be(vocab)
  end

  it 'must not have a blank vocabulary' do
    subject.vocabulary = nil
    expect(subject.vocabulary).to be nil
    expect(subject.valid?).to be false
  end
end
