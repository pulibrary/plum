class FileSetActor < ::CurationConcerns::Actors::FileSetActor
  def attach_file_to_work(*args)
    super.tap do |_result|
      messenger.record_updated(args.first)
    end
  end

  def attach_related_object(resource)
    file_set.apply_depositor_metadata(user)
    resource.related_objects << file_set
    resource.save
  end

  def assign_visibility(resource, file_set_params = {})
    copy_visibility(resource, file_set) unless assign_visibility?(file_set_params)
  end

  def attach_content(file, relation = 'original_file')
    Hydra::Works::AddFileToFileSet.call(file_set, file, relation.to_sym, versioning: false)
  end

  private

    def messenger
      @messenger ||= ManifestEventGenerator.new(Plum.messaging_client)
    end
end
