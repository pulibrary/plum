class FileSetActor < ::CurationConcerns::FileSetActor
  def attach_file_to_work(*args)
    super.tap do |result|
      messenger.record_updated(args.first) if result
    end
  end

  private

    def messenger
      @messenger ||= ManifestEventGenerator.new(Plum.messaging_client)
    end
end
