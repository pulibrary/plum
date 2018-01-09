# frozen_string_literal: true
OmniAuth.config.test_mode = true
RSpec.configure do |config|
  config.before do
    OmniAuth.config.mock_auth[:cas] = nil
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user] # If using Devise
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
  end
end
