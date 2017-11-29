# frozen_string_literal: true
class EphemeraField < ApplicationRecord
  belongs_to :ephemera_project
  belongs_to :vocabulary

  validates :name, presence: true, uniqueness: { scope: :ephemera_project }
  validates :vocabulary, presence: true
end
