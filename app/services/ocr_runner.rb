class OCRRunner
  attr_reader :resource
  def initialize(resource)
    @resource = resource
  end

  def from_file(filename)
    creator_factory.create(filename,
                           params)
  end

  def from_datastream
    Hydra::Derivatives::TempfileService.create(resource.original_file) do |f|
      from_file(f.path)
    end
    resource.update_index
  end

  private

    def creator_factory
      OCRCreator
    end

    def params
      {
        outputs: [
          label: 'ocr',
          url: ocr_file,
          format: :hocr,
          language: language
        ]
      }
    end

    def language
      if parent.try(:ocr_language).blank?
        "eng"
      else
        parent.try(:ocr_language).join("+")
      end
    end

    def parent
      resource.generic_works.first
    end

    def ocr_file
      path = PairtreeDerivativePath.derivative_path_for_reference(resource, "ocr")
      URI("file://#{path}").to_s
    end
end
