class IngestPULFAJob < ApplicationJob
  queue_as :ingest

  # @param [String] mets_file Filename of a PULFA METS file to ingest
  # @param [String] user User to ingest as
  def perform(mets_file, user)
    logger.info "Ingesting PULFA METS #{mets_file}"
    @ingest = IngestService.new(logger)
    @mets = Nokogiri::XML(File.open(mets_file))
    @user = user

    begin
      ingest
    rescue StandardError => e
      logger.warn e.to_s
      logger.warn e.backtrace
    end
  end

  private

    def ingest
      replaces = @mets.xpath('/mets:mets/@OBJID').first.value
      @ingest.delete_duplicates!("replaces_ssim:#{replaces}")
      r = @ingest.minimal_record(ScannedResource, @user, title: [@mets.xpath("//mets:structMap/mets:div/@LABEL").first.value], replaces: replaces)

      pages = []
      @mets.xpath("/mets:mets/mets:fileSec/mets:fileGrp").each do |group|
        master = file_info(group.xpath("mets:file[@USE='master']"))
        service = file_info(group.xpath("mets:file[@USE='deliverable']"))
        if master[:file]
          pages << ingest_page(r, master, service)
        elsif service[:type] == 'application/pdf'
          attach_pdf(r, service)
        end
      end

      # add pages to order
      r.ordered_members = pages
      r.save!
    end

    def file_info(file)
      return {} unless file.length > 0
      file_urn = file.xpath("mets:FLocat/@xlink:href").first.value
      use = file.attribute('USE').value
      fn = (use == 'master') ? master_for(file_urn) : service_for(file_urn)
      groupid = file.xpath('../@ID').first.value
      title = file.xpath("//mets:div[mets:fptr/@FILEID='" + groupid + "']/@LABEL").first.value
      { id: id_for(file_urn), file: fn, use: use, type: file.attribute('MIMETYPE').value, title: title }
    end

    def id_for(file_urn)
      file_urn.sub('.*:', '')
    end

    def master_for(master_urn)
      master_urn.sub('urn:pudl:images:master:', "#{Plum.config['pulfa']['master_files']}/")
    end

    def service_for(service_urn)
      service_urn.sub('urn:pudl:images:deliverable:', "#{Plum.config['pulfa']['service_files']}/")
    end

    def attach_pdf(resource, pdf_info)
      pdf_file_set = FileSet.new
      pdf_file_set.title = ['Original PDF']
      actor = BatchFileSetActor.new(pdf_file_set, @user)
      actor.attach_related_object(resource)
      actor.attach_content(File.open(pdf_info[:file]))
      logger.info "Attached PDF #{pdf_info[:file]}"
    end

    def ingest_page(resource, tiff_info, jp2_info)
      file_set = @ingest.ingest_file(resource, File.new(tiff_info[:file]), @user, {},
                                     title: [tiff_info[:title]], replaces: tiff_info[:id])

      dest = PairtreeDerivativePath.derivative_path_for_reference file_set.id, 'intermediate_file'
      FileUtils.mkdir_p File.dirname(dest)
      FileUtils.cp jp2_info[:file], dest
      logger.info "Copied JP2 #{jp2_info[:file]} to #{dest}"

      file_set
    end
end
