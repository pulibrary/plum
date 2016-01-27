class PairtreeDerivativePath < CurationConcerns::DerivativePath
  class << self
    def extension_for(destination_name)
      case destination_name
      when 'thumbnail'
        ".#{MIME::Types.type_for('jpg').first.extensions.first}"
      when "intermediate_file"
        ".jp2"
      when "ocr"
        ".hocr"
      else
        ".#{destination_name}"
      end
    end

    private

      def derivative_path(object, extension, destination_name)
        file_name = destination_name + extension
        if extension == ".pdf"
          file_name = "#{ResourceIdentifier.new(object.id)}-pdf.pdf"
        end
        "#{path_prefix(object)}-#{file_name}"
      end
  end
end
