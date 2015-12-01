class ReviewerMailer < ApplicationMailer
  def completion_email(curation_concern_id)
    @curation_concern = ActiveFedora::Base.find(curation_concern_id)
    mail(to: Plum.config[:email][:reviewer_address], subject: "[plum] #{@curation_concern.human_readable_type} #{@curation_concern.id} is complete")
  end
end
