class FileInfo
  attr_reader :file_info
  delegate :[], :has_key?, :key?, to: :file_info
  def initialize(file_info)
    @file_info = file_info
  end

  def to_h
    file_info
  end

  def file_name
    file_info["file_name"]
  end

  def file_path
    FilePath.new(file_info["url"])
  end

  def mime_type
    file_info["mime_type"] || mime_type_from_extension
  end

  private

    def mime_type_from_extension
      extension = File.extname(file_path.clean).delete(".")
      Mime::Type.lookup_by_extension(extension).to_s
    end
end
