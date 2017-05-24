module Discovery
  class LayerInfoBuilder < GeoWorks::Discovery::DocumentBuilder::LayerInfoBuilder
    private

      def geom_type
        if geo_concern.model_name == 'MapSet'
          'Scanned Map'
        else
          super
        end
      end

      def format
        if geo_concern.model_name == 'MapSet'
          GeoWorks::ImageFormatService.code('image/tiff')
        else
          super
        end
      end
  end
end
