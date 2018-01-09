# frozen_string_literal: true
require 'active_fedora/cleaner'
require 'pry'

RSpec.configure do |config|
  config.before do
    ActiveFedora::Cleaner.clean! if ActiveFedora::Base.count > 0
  end
end
