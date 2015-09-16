class IIIFPath
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def to_s
    "#{iiif_url}/#{escaped_path}"
  end

  private

    def escaped_path
      CGI.escape(relative_path.to_s)
    end

    def relative_path
      disk_location.relative_path_from(curation_concern_root_path)
    end

    def disk_location
      Pathname.new(
        PairtreeDerivativePath.derivative_path_for_reference(
          OpenStruct.new(id: id),
          "intermediate_file"
        )
      )
    end

    def curation_concern_root_path
      Pathname.new(
        CurationConcerns.config.derivatives_path
      )
    end

    def iiif_url
      Plum.config[:iiif_url]
    end
end
