class VocabularySubauthority < Qa::Authorities::Base
  attr_reader :vocabulary, :subauthority_name

  def initialize(subauthority_name)
    @subauthority_name = subauthority_name
    @vocabulary = Vocabulary.find_by(label: subauthority_name)
  end

  def all
    terms.concat(sub_vocabs).map do |item|
      format_item(item)
    end
  end

  def find(id)
    format_item(VocabularyTerm.find(id))
  end

  private

    def terms
      VocabularyTerm.where(vocabulary_id: @vocabulary.id).to_a
    end

    def sub_vocabs
      Vocabulary.where(parent_id: @vocabulary.id).to_a
    end

    def vocabulary(item)
      item.try(:vocabulary) || item.try(:parent)
    end

    def format_item(item)
      { id: item.id, label: item.label, type: item.class.name, vocabulary: vocabulary(item).try(:label), active: true }.with_indifferent_access
    end
end
