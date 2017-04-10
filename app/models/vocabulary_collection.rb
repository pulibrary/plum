class VocabularyCollection < ApplicationRecord
  belongs_to :vocabulary
  validates :label, :vocabulary, presence: true
end
