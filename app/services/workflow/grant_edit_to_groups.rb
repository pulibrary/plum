# frozen_string_literal: true
module Workflow
  class GrantEditToGroups
    def self.call(target:, **)
      target.edit_groups = ['admin', 'image_editor', 'editor']
    end
  end
end
