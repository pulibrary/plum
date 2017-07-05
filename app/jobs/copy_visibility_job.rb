class CopyVisibilityJob < ApplicationJob
  queue_as :default

  def perform(curation_concern)
    curation_concern.members.each do |member|
      member.visibility = curation_concern.visibility
      member.save!
    end
  end
end
