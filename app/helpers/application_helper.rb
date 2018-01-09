# frozen_string_literal: true
module ApplicationHelper
  def find_authority(parent_id, property)
    parent = ActiveFedora::Base.find(parent_id) if parent_id
    return unless parent && parent.respond_to?(:ephemera_project) && parent.ephemera_project.first
    AuthorityFinder.for(property: property, project: parent.ephemera_project.first)
  end
end
