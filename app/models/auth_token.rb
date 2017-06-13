class AuthToken < ApplicationRecord
  before_create :assign_token
  before_save :clean_groups
  serialize :groups, Array

  private

    def assign_token
      self.token = SecureRandom.hex
    end

    def clean_groups
      self.groups = groups.select(&:present?)
    end
end
