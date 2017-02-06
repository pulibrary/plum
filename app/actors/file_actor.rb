class FileActor < ::Hyrax::Actors::FileActor
  def working_file(file)
    Hyrax::WorkingDirectory.copy_file_to_working_directory(file, file_set.id)
  end
end
