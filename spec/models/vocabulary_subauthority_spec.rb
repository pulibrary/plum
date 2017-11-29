# frozen_string_literal: true
require 'rails_helper'

RSpec.describe VocabularySubauthority, type: :model do
  subject { described_class.new(parent.label) }
  let(:parent) { FactoryGirl.create(:vocabulary, label: 'Parent Vocabulary') }
  let(:child) { FactoryGirl.create(:vocabulary, label: 'Child Vocabulary', parent: parent) }
  let(:term) { FactoryGirl.create(:vocabulary_term, label: 'My Term', vocabulary: parent) }
  it 'lists terms and vocabularies' do
    child_hash = { id: child.id, label: child.label, type: child.class.name, vocabulary: 'Parent Vocabulary', active: true }.with_indifferent_access
    term_hash = { id: term.id, label: term.label, type: term.class.name, vocabulary: 'Parent Vocabulary', active: true }.with_indifferent_access
    expect(subject.all).to contain_exactly(child_hash, term_hash)
  end

  it "orders them by label" do
    term
    FactoryGirl.create(:vocabulary_term, label: 'Aardvark', vocabulary: parent)
    expect(subject.all.map { |x| x[:label] }).to eq ['Aardvark', 'My Term']
  end

  it 'finds terms by their ids' do
    term_hash = { id: term.id, label: term.label, type: term.class.name, vocabulary: 'Parent Vocabulary', active: true }.with_indifferent_access
    expect(subject.find(term.id)).to eq(term_hash)
  end
end
