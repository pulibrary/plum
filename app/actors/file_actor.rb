class FileActor < ::CurationConcerns::Actors::FileActor
  def working_file(file)
    CurationConcerns::WorkingDirectory.copy_file_to_working_directory(file, file_set.id)
  end
end
