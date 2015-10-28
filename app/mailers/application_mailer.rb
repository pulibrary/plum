class ApplicationMailer < ActionMailer::Base
  default from: Plum.config[:email][:from_address]
  layout 'mailer'
end
