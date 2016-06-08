class ContextualPath < CurationConcerns::ContextualPath
  def file_manager
    if parent_presenter
      polymorphic_path([:file_manager, :curation_concerns, :parent, presenter.model_name.singular], parent_id: parent_presenter.id, id: presenter.id)
    else
      polymorphic_path([:file_manager, presenter])
    end
  end
end
