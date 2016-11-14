module Pumpkin::Works
  class AddExternalFileToFileSet
    # Adds a redirecting node for an external file to the file_set
    # @param [Hydra::PCDM::FileSet] file_set the file will be added to
    # @param [String] filename from original file that will be used to create redirects
    # @param [RDF::URI or String] type URI for the RDF.type that identifies the file's role within the file_set
    # @param [Boolean] update_existing whether to update an existing file if there is one. When set to true, performs a create_or_update. When set to false, always creates a new file within file_set.files.
    # @param [Boolean] versioning whether to create new version entries (only applicable if +type+ corresponds to a versionable file)

    def self.call(file_set, filename, type, update_existing: true)
      fail ArgumentError, 'supplied object must be a file set' unless file_set.file_set?

      # TODO: required as a workaround for https://github.com/projecthydra/active_fedora/pull/858
      file_set.save unless file_set.persisted?
      updater = Updater.new(file_set, type, update_existing)
      status = updater.update(filename)
      status ? file_set : false
    end

    class Updater < Hydra::Works::AddFileToFileSet::Updater
      attr_reader :file_set, :current_file, :external_file
      def initialize(file_set, type, update_existing)
        @file_set = file_set
        @current_file = find_or_create_file(type, update_existing)
        # Hydra::PCDM:File behaviors require incoming content to respond to IO requests so send a string acting as IO
        @external_file = StringIO.new('')
      end

      def update(filename)
        attach_attributes(filename)
        persist
        external_file.close
      end

      private

        def attach_attributes(filename)
          current_file.content = external_file
          current_file.original_name = filename
          current_file.mime_type = master_redirect
          Hydra::PCDM::AddTypeToFile.call(current_file, 'http://pcdm.org/use#PreservationMasterFile')
        end

        def master_redirect
          "message/external-body; access-type=URL; URL=\"#{Plum.config[:master_file_service_url]}/#{file_set.source_metadata_identifier}\""
        end
    end
  end
end
