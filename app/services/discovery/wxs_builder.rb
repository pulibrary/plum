require 'active_support/core_ext/hash/indifferent_access'

module Discovery
  class WxsBuilder < GeoWorks::Discovery::DocumentBuilder::Wxs
    def build(document)
      document.wxs_identifier = identifier
      document.wms_path = wms_path
      document.wfs_path = wfs_path
    end

    # Overrides wms_path to add check for file set format
    def wms_path
      return unless @config && visibility && geo_file_set? && file_set_format?
      "#{path}/#{@config[:workspace]}/wms"
    end

    # Overrides wfs_path to add check for file set format
    def wfs_path
      return unless @config && visibility && geo_file_set? && file_set_format?
      "#{path}/#{@config[:workspace]}/wfs"
    end

    private

      # Tests if the file set is a geo_works vector or raster format.
      # @return [Bool]
      def file_set_format?
        geo_mime_type = file_set.solr_document.fetch(:geo_mime_type_ssim, []).first
        GeoWorks::RasterFormatService.include?(geo_mime_type) || GeoWorks::VectorFormatService.include?(geo_mime_type)
      end
  end
end
