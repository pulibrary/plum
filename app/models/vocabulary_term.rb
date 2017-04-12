class VocabularyTerm < ApplicationRecord
  belongs_to :vocabulary
  belongs_to :vocabulary_collection
  validates :label, :vocabulary, presence: true
end
