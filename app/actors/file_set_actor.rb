class FileSetActor < ::CurationConcerns::Actors::FileSetActor
  def attach_file_to_work(*args)
    super.tap do |_result|
      messenger.record_updated(args.first) unless args.first.is_a? GeoConcerns::BasicGeoMetadata
    end
  end

  def attach_content(file, relation = 'original_file')
    Hydra::Works::AddFileToFileSet.call(file_set, file, relation.to_sym, versioning: false)
  end

  private

    def messenger
      @messenger ||= ManifestEventGenerator.new(Plum.messaging_client)
    end

    def file_actor_class
      ::FileActor
    end
end
