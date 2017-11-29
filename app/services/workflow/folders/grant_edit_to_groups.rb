# frozen_string_literal: true
module Workflow
  module Folders
    class GrantEditToGroups
      def self.call(target:, **)
        target.edit_groups = ['admin', 'ephemera_editor']
      end
    end
  end
end
