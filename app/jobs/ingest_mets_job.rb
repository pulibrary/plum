class IngestMETSJob < ActiveJob::Base
  queue_as :ingest

  # @param [String] mets_file Filename of a METS file to ingest
  # @param [String] user User to ingest as
  def perform(mets_file, user)
    logger.info "Ingesting METS #{mets_file}"
    @mets = File.open(mets_file) { |f| Nokogiri::XML(f) }

    r = ScannedResource.new
    r.identifier = ark_id
    r.replaces = pudl_id
    r.source_metadata_identifier = bib_id
    r.apply_depositor_metadata user
    r.rights_statement = 'http://rightsstatements.org/vocab/NKC/1.0/'
    r.apply_remote_metadata
    r.save!
    logger.info "Created ScannedResource: #{r.id}"

    files.each do |f|
      logger.info "Ingesting file #{f[:path]}"
      actor = ::CurationConcerns::FileSetActor.new(FileSet.new, user)
      actor.create_metadata(r, {})
      actor.create_content(decorated_file(f))

      if f[:path] == thumbnail_url
        r.thumbnail_id = file_set.id
        r.save!
      end
    end
  end

  def decorated_file(f)
    IoDecorator.new(File.open(f[:path]), f[:mime_type], File.basename(f[:path]))
  end

  def ark_id
    @mets.xpath("/mets:mets/@OBJID").to_s
  end

  def bib_id
    @mets.xpath("/mets:mets/mets:dmdSec/mets:mdRef/@xlink:href").to_s.gsub(/.*\//, '')
  end

  def pudl_id
    @mets.xpath("/mets:mets/mets:metsHdr/mets:metsDocumentID").first.content.gsub(/\.mets/, '')
  end

  def thumbnail_url
    @mets.xpath("/mets:mets/mets:fileSec/mets:fileGrp[@USE='thumbnail']/mets:file/mets:FLocat/@xlink:href").to_s
  end

  def files
    @mets.xpath("/mets:mets/mets:fileSec/mets:fileGrp[@USE='masters']/mets:file").map do |f|
      file_info(f)
    end
  end

  def file_info(file)
    {
      checksum: file.xpath('@CHECKSUM').to_s,
      mime_type: file.xpath('@MIMETYPE').to_s,
      path: file.xpath('mets:FLocat/@xlink:href').to_s.gsub(/file:\/\//, '')
    }
  end
end
