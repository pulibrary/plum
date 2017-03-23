class PlumDerivativesService
  attr_reader :file_set
  delegate :uri, :mime_type, :mime_type_storage, :replaces, :id, to: :file_set
  def initialize(file_set)
    @file_set = file_set
  end

  def create_derivatives(filename)
    Hydra::Derivatives::Jpeg2kImageDerivatives.create(
      filename,
      outputs: [
        label: 'intermediate_file',
        recipe: recipe,
        service: {
          datastream: 'intermediate_file'
        },
        url: derivative_url('intermediate_file')
      ]
    )
    RunOCRJob.perform_later(id, filename)
  end

  # Remove files as well as shapefile directories
  def cleanup_derivatives
    derivative_path_factory.derivatives_for_reference(self).each do |path|
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
    mime_type_storage.first == "image/tiff"
  end

  private

    # Override the geo_concerns path factory
    def derivative_path_factory
      PairtreeDerivativePath
    end

    # Because of issues with tiffs, scanned maps need a seperate recipe
    def recipe
      file_set.geo_mime_type && file_set.geo_mime_type == "image/tiff" ? :geo : :default
    end
end
