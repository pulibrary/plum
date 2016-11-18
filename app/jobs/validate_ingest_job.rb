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
          if f.original_file.checksum.value != file[:checksum]
            logger.error("Checksum Mismatch: #{file[:replaces]}, FileSet: #{f.id}, mets: #{file[:checksum]}, file: #{Digest::SHA1.hexdigest(File.read(file[:path]))}, fedora: #{f.original_file.checksum.value}")
          end
        else
          logger.error("Missing FileSet: #{file[:replaces]}")
        end
      end
    end
end
