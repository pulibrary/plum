# frozen_string_literal: true
RSpec.configure do |config|
  include ActiveFedora::Noid::RSpec

  config.before :suite do
    disable_production_minter!
  end

  config.after :suite do
    enable_production_minter!
  end
end
