class EphemeraField < ApplicationRecord
  belongs_to :ephemera_project
  belongs_to :vocabulary

  validates :name, uniqueness: { scope: :ephemera_project }
end
