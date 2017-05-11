class ScannedMapDerivativesService
  attr_reader :file_set
  delegate :mime_type, :geo_mime_type, :mime_type_storage, :id, :parent, to: :file_set
  def initialize(file_set)
    @file_set = file_set
  end

  def create_derivatives(filename)
    create_thumbnail_derivative(filename)
    create_jp2k_derivative(filename)
    RunOCRJob.perform_later(id, filename)
  end

  def cleanup_derivatives
    derivative_path_factory.derivatives_for_reference(self).each do |path|
      Rails.logger.debug "Removing derivative: #{path}"
      FileUtils.rm_rf(path)
    end
  end

  # The destination_name parameter has to match up with the file parameter
  # passed to the DownloadsController
  def derivative_url(destination_name)
    path = derivative_path_factory.derivative_path_for_reference(self, destination_name)
    URI("file://#{path}").to_s
  end

  def valid?
    mime_type_storage.first == "image/tiff" && file_set_is_scanned_map?
  end

  private

    def derivative_path_factory
      PairtreeDerivativePath
    end

    def file_set_is_scanned_map?
      geo_mime_type && geo_mime_type == "image/tiff"
    end

    def generate_jp2k?
      parent.visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    def create_jp2k_derivative(filename)
      return unless generate_jp2k?
      Hydra::Derivatives::Jpeg2kImageDerivatives.create(
        filename,
        outputs: [
          label: 'intermediate_file',
          recipe: :geo,
          service: {
            datastream: 'intermediate_file'
          },
          url: derivative_url('intermediate_file')
        ]
      )
    end

    def create_thumbnail_derivative(filename)
      Hydra::Derivatives::ImageDerivatives.create(
        filename,
        outputs: [
          label: :thumbnail,
          format: 'jpg',
          size: '200x150>',
          url: derivative_url('thumbnail')
        ]
      )
    end
end
