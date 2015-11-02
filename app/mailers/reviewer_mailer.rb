class ReviewerMailer < ApplicationMailer
  def completion_email(curation_concern)
    @curation_concern = curation_concern
    mail(to: Plum.config[:email][:reviewer_address], subject: "[plum] #{@curation_concern.human_readable_type} #{@curation_concern.id} is complete")
  end
end
