class PairtreeDerivativePath < CurationConcerns::DerivativePath
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

  def file_name
    return "#{ResourceIdentifier.new(@id)}-#{destination_name}.pdf" if extension == ".pdf"
    super
  end
end
