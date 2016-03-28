class IngestMETSJob < ActiveJob::Base
  queue_as :ingest

  # @param [String] mets_file Filename of a METS file to ingest
  # @param [String] user User to ingest as
  def perform(mets_file, user)
    logger.info "Ingesting METS #{mets_file}"
    mets = METSDocument.new mets_file

    r = ScannedResource.new
    r.identifier = mets.ark_id
    r.replaces = mets.pudl_id
    r.source_metadata_identifier = mets.bib_id
    r.apply_depositor_metadata user
    r.rights_statement = 'http://rightsstatements.org/vocab/NKC/1.0/'
    r.viewing_direction = mets.viewing_direction
    r.apply_remote_metadata
    r.save!
    logger.info "Created ScannedResource: #{r.id}"

    mets.files.each do |f|
      logger.info "Ingesting file #{f[:path]}"
      file_set = FileSet.new
      actor = ::CurationConcerns::FileSetActor.new(file_set, user)
      actor.create_metadata(r, mets.file_opts(f))
      actor.create_content(mets.decorated_file(f))

      if f[:path] == mets.thumbnail_path
        r.thumbnail_id = file_set.id
        r.save!
      end
    end
  end
end
