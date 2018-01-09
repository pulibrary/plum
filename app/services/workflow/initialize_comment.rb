# frozen_string_literal: true
module Workflow
  module InitializeComment
    def self.call(entity, user, comment)
      agent = Sipity::Agent.find_by(proxy_for_id: user.id, proxy_for_type: "User")
      Sipity::Comment.create!(entity_id: entity.id, agent_id: agent.id, comment: comment)
    end
  end
end
