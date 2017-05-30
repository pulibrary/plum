module Discovery
  class RelationshipBuilder
    attr_reader :geo_work

    def initialize(geo_work)
      @geo_work = geo_work
    end

    def build(document)
      document.source = source
      document.suppressed = suppressed
    end

    private

      def source
        return unless image_work? && parent?
        parents
      end

      def suppressed
        return unless image_work? && parent?
        true
      end

      def image_work?
        geo_work.model_name.to_s == 'ImageWork'
      end

      def parent?
        geo_work.member_of_ids.count > 0
      end

      def parents
        geo_work.member_of_ids.map do |id|
          map_set = MapSet.search_with_conditions(id: id).first
          map_set_presenter = MapSetShowPresenter.new(SolrDocument.new(map_set), nil)
          Discovery::SlugBuilder.new(map_set_presenter).slug
        end
      end
  end
end
