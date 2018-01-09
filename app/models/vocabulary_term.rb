# frozen_string_literal: true
class VocabularyTerm < ApplicationRecord
  belongs_to :vocabulary
  validates :label, :vocabulary, presence: true
end
