# frozen_string_literal: true
class BatchFileSetActor < ::Hyrax::Actors::FileSetActor
  # def attach_file_to_work(work, file_set, file_set_params)
  #   copy_visibility(work, file_set) unless assign_visibility?(file_set_params)
  #   work.members << file_set
  #   work.save
  #
  #   Hyrax.config.callback.run(:after_create_fileset, file_set, user)
  # end

  # Adds a FileSet to the work using ore:Aggregations.
  # Locks to ensure that only one process is operating on
  # the list at a time.
  def attach_file_to_work(work, file_set_params = {})
    acquire_lock_for(work.id) do
      # Ensure we have an up-to-date copy of the members association, so
      # that we append to the end of the list.
      work.reload unless work.new_record?
      copy_visibility(work, file_set) unless assign_visibility?(file_set_params)
      work.members << file_set
      set_representative(work, file_set)
      set_thumbnail(work, file_set)

      # Save the work so the association between the work and the file_set is persisted (head_id)
      # NOTE: the work may not be valid, in which case this save doesn't do anything.
      work.save
    end
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
