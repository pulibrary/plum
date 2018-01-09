# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  default from: Plum.config[:notifier_email_address]
  layout 'mailer'
end
