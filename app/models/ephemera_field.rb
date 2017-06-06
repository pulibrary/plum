class EphemeraField < ApplicationRecord
  belongs_to :ephemera_project
  belongs_to :vocabulary
end
