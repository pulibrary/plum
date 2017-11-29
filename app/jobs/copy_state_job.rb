# frozen_string_literal: true
class CopyStateJob < ApplicationJob
  queue_as :default

  def perform(curation_concern)
    parent = entity_for(curation_concern)
    curation_concern.members.each do |member|
      child = entity_for(member)
      child.workflow_state = parent.workflow_state
      child.save!
    end
  end

  def entity_for(curation_concern)
    Sipity::Entity.where(proxy_for_global_id: curation_concern.to_global_id.to_s).first
  end
end
