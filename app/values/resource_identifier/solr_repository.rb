class ResourceIdentifier
  ##
  # Repository for querying solr for a single or multiple IDs and getting back a
  # document object which can return its dependants and timestamps.
  class SolrRepository
    class << self
      # @param [Array<Integer> OR Integer] id ID or array of IDs of records to
      #   query for.
      # @return [Record, #timestamp, #dependant_ids] Solr-record powered record
      #   which can return its timestamp and dependant ids.
      def find(id)
        id = Array.wrap(id)
        return CompositeRecord.new({}) if id.blank?
        records = solr.query(solr_query(id), fl: "timestamp member_ids_ssim", sort: "timestamp desc").map do |r|
          Record.new(r)
        end
        CompositeRecord.new(records)
      end

      private

      def solr_query(id)
        "id:(#{id.join(' OR ')})"
      end

      def solr
        ActiveFedora::SolrService
      end
    end

    class Record
      attr_reader :record
      delegate :fetch, :[], to: :record
      def initialize(record)
        @record = record
      end

      def dependant_ids
        record.fetch("member_ids_ssim", [])
      end

      def timestamp
        record["timestamp"]
      end
    end

    class CompositeRecord
      attr_reader :records
      def initialize(records)
        @records = records
      end

      def timestamp
        CompositeTimestamp.new(
          records.flat_map(&:timestamp)
        ).to_s
      end

      def method_missing(meth_name, *args, &block)
        records.flat_map do |record|
          record.__send__(meth_name, *args, &block)
        end.compact
      end
    end
  end
end
