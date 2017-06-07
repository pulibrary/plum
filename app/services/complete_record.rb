class CompleteRecord
  attr_reader :record, :identifier

  def initialize(obj)
    @record = obj
    @identifier = obj.identifier
  end

  def complete
    if identifier.present?
      update_metadata
    else
      mint_identifier
    end
  end

  private

    def update_metadata
      return if minter_user == "apitest"
      minter.modify(identifier, metadata)
    end

    def minter_user
      Ezid::Client.config.user
    end

    def minter
      Ezid::Identifier
    end

    def metadata
      {
        dc_publisher: 'Princeton University Library',
        dc_title: title,
        dc_type: 'Text',
        target: url
      }
    end

    def title
      record.title.join('; ')
    end

    def url
      if record.try(:source_metadata_identifier).blank?
        return ManifestBuilder::ManifestHelper.new.polymorphic_url(record)
      elsif RemoteRecord.bibdata?(record.source_metadata_identifier.first)
        return "https://pulsearch.princeton.edu/catalog/#{record.source_metadata_identifier.first}#view"
      else
        return "http://findingaids.princeton.edu/collections/#{record.source_metadata_identifier.first.tr('_', '/')}"
      end
    end

    def mint_identifier
      record.identifier = [minter.mint(metadata).id]
      record.save
    end
end
