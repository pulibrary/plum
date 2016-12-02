class PairtreeDerivativePath < CurationConcerns::DerivativePath
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
