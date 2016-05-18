class FileSetActor < ::CurationConcerns::Actors::FileSetActor
  def attach_file_to_work(*args)
    super.tap do |_result|
      messenger.record_updated(args.first)
    end
  end

  private

    def messenger
      @messenger ||= ManifestEventGenerator.new(Plum.messaging_client)
    end
end
