module IuMetadata
  module Preingest
    class Variations
      include PreingestableDocument
      FILE_PATTERN = '*.xml'

      def initialize(source_file)
        @source_file = source_file
        @local = IuMetadata::VariationsRecord.new(source_uri, open(source_file))
        @source_title = ['Variations XML']
      end
      attr_reader :source_file, :source_title, :local

      def default_attributes
        super.merge(local.default_attributes)
      end

      delegate :source_metadata_identifier, to: :local
      delegate :multi_volume?, :collections, to: :local
      delegate :files, :structure, :volumes, :thumbnail_path, to: :local
    end
  end
end
