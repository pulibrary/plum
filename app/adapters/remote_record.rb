##
# An adapter class to handle the difference between PUL's opinions on metadata
# and CC's "open world" assumptions. IE the date_created field is single-valued
# in MARC records, but multi-valued in Curation Concerns.
class RemoteRecord < SimpleDelegator
  class << self
    def retrieve(id)
      if id.present?
        result = new(PulMetadataServices::Client.retrieve(id))
        raise JSONLDRecord::MissingRemoteRecordError if result.source.blank?
        result
      else
        Null.retrieve(id)
      end
    end

    def bibdata?(source_metadata_identifier)
      PulMetadataServices::Client.bibdata?(source_metadata_identifier)
    end
  end

  def attributes
    result = super
    result[:date] = Array(result.delete(:date_created))
    result[:description] = Array(result[:description]).first
    result.delete :heldBy # TODO: map codes to locations (see plum#1001)
    result[:member_of_collections] = find_or_create(result.delete(:memberOf))
    result
  end

  # Null class.
  class Null
    include Singleton
    class << self
      def retrieve(_id)
        instance
      end
    end

    def source
      nil
    end

    def attributes
      {}
    end
  end

  private

    def find_or_create(cols)
      cols.map { |col| find_or_create_collection(col[:title], col[:identifier]) }
    end

    def find_or_create_collection(title, slug)
      return unless title.present?
      existing = Collection.where exhibit_id_ssim: slug
      return existing.first if existing.first

      col = Collection.new title: [title], exhibit_id: slug
      col.save!
      col
    end
end
