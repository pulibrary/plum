module PreingestableDocument
  DEFAULT_ATTRIBUTES = {
    state: 'final_review',
    viewing_direction: 'left-to-right',
    rights_statement: 'http://rightsstatements.org/vocab/NKC/1.0/',
    visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  }

  def attributes
    { default: default_attributes, local: local_attributes, remote: remote_attributes }
  end

  def default_attributes
    DEFAULT_ATTRIBUTES
  end

  def local_attributes
    { identifier: identifier,
      replaces: replaces,
      source_metadata_identifier: source_metadata_identifier,
      viewing_direction: viewing_direction
    }
  end

  def remote_attributes
    remotes = {}
    remote_data.attributes.each do |k, v|
      remotes[k] = v.map(&:to_s)
    end
    remotes
  end

  def source_metadata
    return unless remote_data.source
    remote_data.source.dup.try(:force_encoding, 'utf-8')
  end

  def resource_class
    multi_volume? ? MultiVolumeWork : ScannedResource
  end

  private

    def remote_data
      @remote_data ||= remote_metadata_factory.retrieve(source_metadata_identifier)
    end

    def remote_metadata_factory
      if RemoteRecord.bibdata?(source_metadata_identifier)
        JSONLDRecord::Factory.new(resource_class)
      else
        RemoteRecord
      end
    end
end
