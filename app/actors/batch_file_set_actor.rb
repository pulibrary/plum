class BatchFileSetActor < ::Hyrax::Actors::FileSetActor
  def attach_file_to_work(work, file_set, file_set_params)
    copy_visibility(work, file_set) unless assign_visibility?(file_set_params)
    work.members << file_set
    work.save

    Hyrax.config.callback.run(:after_create_fileset, file_set, user)
  end

  def attach_related_object(resource)
    file_set.apply_depositor_metadata(user)
    resource.related_objects << file_set
    resource.save
  end

  def attach_content(file, relation = 'original_file')
    Hydra::Works::AddFileToFileSet.call(file_set, file, relation.to_sym, versioning: false)
  end

  private

    def file_actor_class
      ::FileActor
    end
end
