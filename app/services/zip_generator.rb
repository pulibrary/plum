class ZipGenerator
  attr_reader :file_set_ids
  def initialize(file_set_ids:)
    @file_set_ids = file_set_ids
  end

  def generate!
    Zip::File.open(tmp_file.path, Zip::File::CREATE) do |zipfile|
      file_names.each do |file_name|
        zipfile.add(file_name.basename, file_name)
      end
    end
    tmp_file.path
  end

  def file_sets
    @file_sets ||= file_set_ids.map do |id|
      ActiveFedora::Base.find(id)
    end
  end

  def file_names
    @file_names ||= file_sets.map do |file_set|
      Pathname.new(file_set.local_file)
    end
  end

  def tmp_file
    @tmp_file ||= Tempfile.new(["generated_zip", ".zip"])
  end
end
