class EphemeraProject < ApplicationRecord
  has_many :ephemera_fields

  validates :name, presence: true
end
