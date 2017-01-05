class ReviewerMailer < ApplicationMailer
  def notify(args)
    @message = args[:message]
    @work_id = args[:work_id]
    @title = args[:title]
    @url = args[:url]
    addresses = args[:addresses]
    mail(to: addresses, subject: args[:subject]) if addresses.any?
  end
end
