class ReviewerMailer < ApplicationMailer
  def notify(curation_concern_id, state)
    @curation_concern = ActiveFedora::Base.find(curation_concern_id)
    @state = state

    addresses = Role.where(name: "notify_#{state}").first_or_create.users.map(&:email)
    subject = "[plum] #{@curation_concern.human_readable_type} #{curation_concern_id}: #{state}"
    mail(to: addresses, subject: subject) if addresses.any?
  end
end
