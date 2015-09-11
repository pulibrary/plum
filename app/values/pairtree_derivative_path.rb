class PairtreeDerivativePath < CurationConcerns::DerivativePath
  class << self
    def extension_for(destination_name)
      case destination_name
      when 'thumbnail'
        ".#{MIME::Types.type_for('jpg').first.extensions.first}"
      when "intermediate_file"
        ".jp2"
      else
        ".#{destination_name}"
      end
    end
  end
end
