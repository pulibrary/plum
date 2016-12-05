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
      vols = @mets.multi_volume? ? @mets.volume_ids : [nil]
      vols.each do |vol|
        files = vol ? @mets.files_for_volume(vol) : @mets.files
        files.each do |file|
          fs = FileSet.where(digest_ssim: "urn:sha1:#{file[:checksum]}").first
          if fs
            logger.info "#{file[:replaces]} => #{fs.id}"
          else
            fs2 = FileSet.where(digest_ssim: "urn:sha1:#{sha_from_disk(file)}").first
            if fs2
              logger.warn "#{file[:replaces]} => #{fs2.id} (matches checksum from disk)"
            else
              logger.error "#{file[:replaces]}: no FileSet found matching checksum from METS or disk"
            end
          end
        end
      end
    end

    def sha_from_disk(file)
      Digest::SHA1.hexdigest(File.read(file[:path]))
    end
end
