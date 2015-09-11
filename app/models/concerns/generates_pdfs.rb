module GeneratesPdfs
  # Generate a pdf representation of the work

  def to_pdf
    pdf = Prawn::Document.new(info: pdf_metadata, margin: 0)
    generic_files.each do |generic_file|
      # using local_path_for_file from Hydra::Works::GenericFile::VirusCheck
      # This _should_ be calling the IIIF server, rendering JPG or PNG images
      # to a tmpfile the path to and passing those images to the pdf
      # @example the rough idea...
      #   path_to_tmp_file = generate_image_from_loris(max_height: 792, max_width: 612)
      #   pdf.image path_to_tmp_file
      pdf.image generic_file.send(:local_path_for_file, generic_file.original_file.content), height: 792
    end
    pdf
  end

  # Generate pdf representation of the object and render it to a file at +path+

  def render_pdf(path)
    to_pdf.render_file(path)
  end

  private

    # Render the value of +field_symbol+ in a human readable format.

    def render_field(field_symbol)
      value = send(field_symbol)
      if value.is_a?(Array)
        value.join(", ")
      else
        value
      end
    end

    def pdf_metadata
      metadata_to_insert = { Producer: I18n.t('curation_concerns.institution.name') }
      pdf_metadata_fields.each do |field_symbol|
        metadata_to_insert[field_symbol.to_s.camelize.to_sym] = render_field(field_symbol) unless render_field(field_symbol).nil?
      end
      metadata_to_insert
    end

    # Fields on the work that contain relevant metadata

    def pdf_metadata_fields
      self.class.fields.select { |field_symbol| !non_pdf_metadata_fields.include?(field_symbol) }
    end

    # Fields on the work containing metadata that's not relevant for pdfs

    def non_pdf_metadata_fields
      [:create_date, :has_model, :representative, :depositor, :relative_path, :import_url,
       :date_uploaded, :date_created, :date_modified, :modified_date, :source_metadata,
       :viewing_direction, :viewing_hint]
    end
end
