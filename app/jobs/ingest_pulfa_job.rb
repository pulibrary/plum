class IngestPULFAJob < ApplicationJob
  queue_as :ingest

  # @param [String] mets_file Filename of a PULFA METS file to ingest
  # @param [String] user User to ingest as
  def perform(mets_file, user)
    logger.info "Ingesting PULFA METS #{mets_file}"
    @mets = Nokogiri::XML(File.open(mets_file))
    @user = user
    @pages = []

    ingest
  end

  private

    def ingest
      r = ScannedResource.new
      r.title = [@mets.xpath("//mets:structMap/mets:div/@LABEL").first.value]
      r.replaces = @mets.xpath('/mets:mets/@OBJID').first.value
      r.rights_statement = 'http://rightsstatements.org/vocab/NKC/1.0/'
      r.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      r.apply_depositor_metadata @user
      r.save!
      Workflow::InitializeState.call(r, 'book_works', 'final_review')
      logger.info "Created ScannedResource #{r.id} (#{r.replaces})"

      @mets.xpath("/mets:mets/mets:fileSec/mets:fileGrp").map do |group|
        master = file_info(group.xpath("mets:file[@USE='master']"))
        service = file_info(group.xpath("mets:file[@USE='deliverable']"))
        if master[:file]
          ingest_page(r, master, service)
        elsif service[:type] == 'application/pdf'
          attach_pdf(r, service)
        end
      end

      # add pages to order
      r.ordered_members = @pages
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
      file_set = FileSet.new
      file_set.title = [tiff_info[:title]]
      file_set.replaces = tiff_info[:id]
      actor = BatchFileSetActor.new(file_set, @user)
      actor.create_metadata(resource, {})
      actor.create_content(File.open(tiff_info[:file]))
      @pages << file_set
      logger.info "Ingested TIFF #{tiff_info[:file]}"

      dest = PairtreeDerivativePath.derivative_path_for_reference file_set.id, 'intermediate_file'
      FileUtils.mkdir_p File.dirname(dest)
      FileUtils.cp jp2_info[:file], dest
      logger.info "Copied JP2 #{jp2_info[:file]} to #{dest}"
    end
end
