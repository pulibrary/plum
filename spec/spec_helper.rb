require 'simplecov'
require 'active_fedora/noid/rspec'

if ENV['CI']
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

RSpec.configure do |config|
  include ActiveFedora::Noid::RSpec

  config.before(:suite) { disable_production_minter! }
  config.after(:suite)  { enable_production_minter! }

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
