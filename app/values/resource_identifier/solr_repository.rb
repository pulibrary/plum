# frozen_string_literal: true
class ResourceIdentifier
  ##
  # Repository for querying solr for a single ID and getting back a
  #   document object which can return its timestamp.
  class SolrRepository
    class << self
      # @param [String] id ID of record to query Solr for
      # @return [Record, #timestamp] Solr-record powered record which can
      #   return its timestamp.
      def find(id)
        Record.new(
          solr.query(
            solr_query(id),
            fl: "timestamp member_ids_ssim",
            sort: "timestamp desc",
            rows: 1
          ).first
        )
      end

      private

      def solr_query(id)
        "id:#{id} OR generic_work_ids_ssim:#{id}"
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

      def timestamp
        record["timestamp"]
      end
    end
  end
end
