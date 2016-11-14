class PreingestableMETS < METSDocument
  include PreingestableDocument
  FILE_PATTERN = '*.mets'

  def source_title
    ['METS XML']
  end

  def yaml_file
    source_file.sub(/\.mets$/, '.yml')
  end

  def volumes
    volumes = []
    volume_ids.each do |volume_id|
      volume_hash = {}
      volume_hash[:title] = [label_for_volume(volume_id)]
      volume_hash[:structure] = structure_for_volume(volume_id)
      volume_hash[:files] = files_for_volume(volume_id)
      volumes << volume_hash
    end
    volumes
  end

  def identifier
    ark_id
  end

  def replaces
    pudl_id
  end

  def source_metadata_identifier
    bib_id
  end

  def files
    add_file_attributes super
  end

  def collections
    Array.wrap(collection_slugs)
  end

  private

    def add_file_attributes(file_hash_array)
      file_hash_array.each do |f|
        f[:file_opts] = file_opts(f)
        f[:attributes] ||= {}
        f[:attributes][:title] = [file_label(f[:id])]
        f[:attributes][:replaces] = "#{pudl_id}/#{File.basename(f[:path], File.extname(f[:path]))}"
      end
      file_hash_array
    end

    def files_for_volume(volume_id)
      add_file_attributes super
    end
end
