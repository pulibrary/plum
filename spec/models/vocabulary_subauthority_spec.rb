require 'rails_helper'

RSpec.describe VocabularySubauthority, type: :model do
  let(:parent) { FactoryGirl.create(:vocabulary, label: 'Parent Vocabulary') }
  let(:child) { FactoryGirl.create(:vocabulary, label: 'Child Vocabulary', parent: parent) }
  let(:term) { FactoryGirl.create(:vocabulary_term, label: 'My Term', vocabulary: parent) }
  subject { described_class.new(parent.label) }

  it 'lists terms and vocabularies' do
    child_hash = { id: child.id, label: child.label, type: child.class.name }
    term_hash = { id: term.id, label: term.label, type: term.class.name }
    expect(subject.all).to contain_exactly(child_hash, term_hash)
  end

  it 'finds terms by their ids' do
    term_hash = { id: term.id, label: term.label, type: term.class.name }
    expect(subject.find(term.id)).to eq(term_hash)
  end
end
