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
    case destination_name
    when 'thumbnail'
      ".#{MIME::Types.type_for('jpg').first.extensions.first}"
    when "intermediate_file"
      ".jp2"
    when "ocr"
      ".hocr"
    when "gray-pdf"
      ".pdf"
    when "color-pdf"
      ".pdf"
    else
      ".#{destination_name}"
    end
  end
end
