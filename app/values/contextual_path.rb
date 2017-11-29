# frozen_string_literal: true
class ContextualPath < Hyrax::ContextualPath
  def file_manager
    action_path(:file_manager)
  end

  def structure
    action_path(:structure)
  end

  private

    def action_path(action)
      if parent_presenter
        polymorphic_path([action, :hyrax, :parent, presenter.model_name.singular], parent_id: parent_presenter.id, id: presenter.id)
      else
        polymorphic_path([action, presenter])
      end
    end
end
