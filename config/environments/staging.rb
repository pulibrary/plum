require_relative 'production'

Rails.application.configure do
  config.action_mailer.default_url_options = { host: 'hydra-dev.princeton.edu' }
  config.action_mailer.delivery_method = :sendmail
end
