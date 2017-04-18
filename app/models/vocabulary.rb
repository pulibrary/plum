class Vocabulary < ApplicationRecord
  belongs_to :parent, class_name: "Vocabulary"
  validates :label, presence: true
end
