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
      ocr_output = from_file(f.path)
      attach_ocr(ocr_filename(ocr_output))
    end
    resource.save
  end

  private

    def attach_ocr(filename)
      basename = File.basename(filename) if filename
      iodec = Hydra::Derivatives::IoDecorator.new(File.open(filename, 'rb'), 'text/html', basename)
      Hydra::Works::AddFileToFileSet.call(resource, iodec, :extracted_text)
    end

    def ocr_filename(ocr_output)
      ocr_output.first[:url].sub(/^file:/, '')
    end

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
      return try_language(:ocr_language).join("+") unless try_language(:ocr_language).blank?
      return try_language(:language).join("+") unless try_language(:language).blank?
      "eng"
    end

    def try_language(field)
      (parent.try(field) || []).select { |lang| !Tesseract.languages[lang.to_sym].nil? }
    end

    def parent
      resource.in_works.first
    end

    def ocr_file
      path = PairtreeDerivativePath.derivative_path_for_reference(resource, "ocr")
      URI("file://#{path}").to_s
    end
end
