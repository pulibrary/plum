require 'rails_helper'

RSpec.describe VocabularySelectService do
  let(:vocabulary_label) { "Subjects" }
  let(:vocabulary) do
    Vocabulary.create!(label: "Subjects").tap do |vocab|
      Vocabulary.create!(label: "Test", parent: vocab).tap do |vocab_2|
        VocabularyTerm.create!(vocabulary: vocab_2, label: "English")
      end
    end
  end
  subject(:select_service) { described_class.new(vocabulary_label) }
  before do
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete(vocabulary_label)
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Test")
    vocabulary
  end
  after do
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete(vocabulary_label)
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Test")
  end
  context "when given a vocabulary with terms" do
    let(:vocabulary_label) { "Test" }
    it "returns options without child_terms" do
      expect(select_service.select_all_options.first.child_terms).to eq []
    end
  end
  context "when given a vocabulary with a sub-vocabulary" do
    it "returns options with child_terms" do
      expect(select_service.select_all_options.first.child_terms).not_to be_empty
    end
  end
end
