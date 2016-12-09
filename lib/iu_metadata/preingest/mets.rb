module IuMetadata
  module Preingest
    class Mets
      include PreingestableDocument

      def initialize(source_file)
        @source_file = source_file
        @local = IuMetadata::METSRecord.new(source_uri, open(source_file))
        @source_title = ['METS XML']
      end
      attr_reader :source_file, :source_title, :local

      delegate :source_metadata_identifier, to: :local
      delegate :multi_volume?, :collections, to: :local
      delegate :files, :structure, :volumes, :thumbnail_path, to: :local
    end
  end
end
