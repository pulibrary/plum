require_relative 'production'

Rails.application.configure do
  config.action_mailer.default_url_options = { host: 'hydra-dev.princeton.edu', protocol: 'https' } # FIXME: find IU equivalent link
  config.action_mailer.delivery_method = :sendmail
end
