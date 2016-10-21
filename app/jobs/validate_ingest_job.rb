class ValidateIngestJob < ActiveJob::Base
  queue_as :ingest

  # @param [String] mets_file Filename of a METS file to validate
  def perform(mets_file)
    logger.info "Validating files ingested from METS #{mets_file}"
    @mets = METSDocument.new mets_file

    validate
  end

  private

    def validate
      @mets.files.each do |file|
        f = FileSet.where(replaces_ssim: file[:replaces]).first
        if f
          warn(file, f.id, "Checksum Mismatch") unless f.original_file.checksum.value == file[:checksum]
        else
          warn(file, nil, "Missing FileSet")
        end
      end
    end

    def warn(file, fileset, message)
      logger.error "#{message}: #{file[:replaces]} (#{fileset})"
    end
end
