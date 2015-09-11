class PersistPairtreeDerivatives < CurationConcerns::PersistDerivatives
  # Open the output file to write and yield the block to the
  # file.  It will make the directories in the path if
  # necessary.
  def self.output_file(object, destination_name, &blk)
    name = PairtreeDerivativePath.derivative_path_for_reference(object, destination_name)
    output_file_dir = File.dirname(name)
    FileUtils.mkdir_p(output_file_dir) unless File.directory?(output_file_dir)
    File.open(name, 'wb', &blk)
  end
end
