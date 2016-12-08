class PairtreeDerivativePath < CurationConcerns::DerivativePath
  def initialize(object, destination_name = nil)
    @object = object
    @id = object.is_a?(String) ? object : object.id
    @destination_name = destination_name.gsub(/^original_file_/, '') if destination_name
  end

  def path_prefix
    geo_path_prefix || derivatives_path_prefix
  end

  def geo_path_prefix
    return unless @object.respond_to?(:geo_mime_type)
    return if @object.geo_mime_type.nil? || @object.geo_mime_type.empty?
    Pathname.new(Plum.config[:geo_derivatives_path]).join(pair_path)
  end

  def derivatives_path_prefix
    Pathname.new(CurationConcerns.config.derivatives_path).join(pair_path)
  end

  def file_name
    return unless destination_name
    if extension == ".pdf"
      "#{ResourceIdentifier.new(id)}-#{destination_name}.pdf"
    else
      destination_name + extension
    end
  end

  def extension
    value = extensions[destination_name]
    value ? value : ".#{destination_name}"
  end

  def extensions
    {
      "thumbnail" => ".#{MIME::Types.type_for('jpg').first.extensions.first}",
      "intermediate_file" => ".jp2",
      "ocr" => ".hocr",
      "gray-pdf" => ".pdf",
      "color-pdf" => ".pdf",
      "display_raster" => ".tif",
      "display_vector" => ".zip"
    }
  end
end
