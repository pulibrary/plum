module IuMetadata
  module Preingest
    class Contentdm
      include PreingestableDocument

      def initialize(source_file)
        @source_file = source_file
        @local = IuMetadata::ContentdmRecord.new(source_uri, open(source_file))
        @source_title = ['Contentdm XML']
      end
      attr_reader :source_file, :source_title, :local

      def attribute_sources
        result = super
        result.delete(:remote)
        result
      end

      delegate :source_metadata_identifier, to: :local
      delegate :multi_volume?, :collections, to: :local
      delegate :files, :structure, :volumes, :thumbnail_path, to: :local
    end
  end
end
