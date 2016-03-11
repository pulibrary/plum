module VoyagerUpdater
  class Dump
    attr_reader :url
    def initialize(url)
      @url = url
    end

    def update_ids
      parsed_json["ids"]["update_ids"].map { |x| x["id"] }
    end

    def create_ids
      parsed_json["ids"]["create_ids"].map { |x| x["id"] }
    end

    def ids_needing_updated
      @ids_needing_updated ||=
        begin
          relevant_ids.each_slice(100).flat_map do |ids|
            run_query(query(ids), fl: "id").map { |x| x["id"] }
          end
        end
    end

    private

      def query(ids)
        "source_metadata_identifier_ssim:(#{ids.join(' OR ')})"
      end

      def run_query(query, args)
        args = args.merge(qt: 'standard')
        result = ActiveFedora::SolrService.instance.conn.post(ActiveFedora::SolrService.select_path, params: args, data: { q: query })
        result['response']['docs']
      end

      def relevant_ids
        update_ids + create_ids
      end

      def parsed_json
        @parsed_json ||= JSON.parse(open(url).read)
      end
  end
end
