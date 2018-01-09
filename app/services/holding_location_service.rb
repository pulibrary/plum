# frozen_string_literal: true
module HoldingLocationService
  mattr_accessor :authority
  self.authority = HoldingLocationAuthority.new

  def self.select_options
    authority.all.map { |element| [element['label'], element['id']] }.sort
  end

  def self.find(id)
    HoldingLocation.new(authority.find(id))
  end

  class HoldingLocation
    def initialize(hash)
      @holding_location = hash || {}
    end

    def email
      @holding_location['contact_email']
    end

    def label
      @holding_location['label']
    end

    def phone
      @holding_location['phone_number']
    end

    def address
      @holding_location['address']
    end
  end
end
