class SearchBuilder
  class JoinChildrenQuery
    attr_reader :parent_query
    def initialize(parent_query)
      @parent_query = parent_query
    end

    def to_s
      "{!lucene}#{joined_queries}"
    end

    def joined_queries
      queries.map do |query|
        "(#{dismax_join(send(query))})"
      end.join(" OR ")
    end

    private

      def queries
        [
          :main_query,
          :query_children,
          :query_file_sets,
          :query_child_file_sets
        ]
      end

      def dismax_join(query)
        "#{query}{!dismax}#{parent_query}"
      end

      def main_query
        ""
      end

      def query_children
        "{!join from=ordered_by_ssim to=id}"
      end

      def query_file_sets
        "{!join from=ordered_by_ssim to=id}"
      end

      def query_child_file_sets
        query_children + query_file_sets
      end
  end
end
