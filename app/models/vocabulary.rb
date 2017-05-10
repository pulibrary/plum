class Vocabulary < ApplicationRecord
  belongs_to :parent, class_name: "Vocabulary"
  validates :label, presence: true
  after_create :register_authority
  has_many :vocabulary_terms

  def register_authority
    Qa::Authorities::Local.register_subauthority(label, 'VocabularySubauthority')
  end
end
