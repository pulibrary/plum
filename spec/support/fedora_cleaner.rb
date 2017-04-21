require 'active_fedora/cleaner'
require 'pry'

RSpec.configure do |config|
  config.before :each do
    ActiveFedora::Cleaner.clean! if ActiveFedora::Base.count > 0
  end
end
