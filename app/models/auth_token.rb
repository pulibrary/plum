class AuthToken < ApplicationRecord
  before_create :assign_token
  serialize :groups, Array

  private

    def assign_token
      self.token = SecureRandom.hex
    end
end
