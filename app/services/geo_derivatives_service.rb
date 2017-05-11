class GeoDerivativesService < GeoWorks::FileSetDerivativesService
  # Remove files as well as shapefile directories
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

  private

    # Override the geo_concerns path factory
    def derivative_path_factory
      PairtreeDerivativePath
    end
end
