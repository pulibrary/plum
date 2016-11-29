module IuMetadata
  class AttributeIngester
    def initialize(source_id, source_attributes, factory: ScannedResource, context: CONTEXT)
      @source_id = source_id
      @source_attributes = source_attributes
      @factory = factory
      @context = context
    end
    attr_reader :source_id, :source_attributes, :factory, :context

    # Runs full transformation pipeline:
    #
    # * assigns outbound_graph to proxy_record
    # * filters proxy_record attributes down to those acquired from outbound_graph
    # * sets attribute values as RDF::Literal for single values, ActiveTriples::Relation for multiple
    # * (ActiveTriple relations may have non-deterministic order)
    #
    # @return [Hash] RDF attributes for the target factory object
    def attributes
      @attributes ||=
        begin
          Hash[
            cleaned_attributes.map do |k, _|
              if k.in? singular_fields
                [k, proxy_record.get_values(k, literal: true).first]
              else
                [k, proxy_record.get_values(k, literal: true)]
              end
            end
          ]
        end
    end

    # Runs abbreviated transformation pipeline:
    #
    # * checks outbound_statements against factory predicates
    # * sets attribute values simple values for single values, Array for multiple
    # * (Array values should have a deterministic order)
    #
    # @return [Hash] Array, raw-valued attributes for target factory object
    def raw_attributes
      @raw_attributes ||=
        begin
          raw_hash = {}
          outbound_statements.each do |s|
            target_property = outbound_predicates_to_properties[s.predicate]
            next if target_property.nil?
            if target_property.in? singular_fields
              raw_hash[target_property] = s.object.value
            else
              raw_hash[target_property] ||= []
              raw_hash[target_property] << s.object.value
            end
          end
          raw_hash
        end
    end

    private

      CONTEXT = YAML.load(File.read(Rails.root.join('config/context.yml')))

      # used by both pipelines
      def outbound_statements
        @outbound_statements ||=
          begin
            jsonld_hash = {}
            jsonld_hash['@context'] = context["@context"]
            jsonld_hash['@id'] = source_id
            jsonld_hash.merge!(source_attributes.stringify_keys)
            JSON::LD::API.toRdf(jsonld_hash)
          end
      end

      # used by full pipeline, only
      def outbound_graph
        @outbound_graph ||= RDF::Graph.new << outbound_statements
      end

      # used by full pipeline, only
      def proxy_record
        @proxy_record ||= factory.new.tap do |resource|
          outbound_graph.each do |statement|
            resource.resource << RDF::Statement.new(resource.rdf_subject, statement.predicate, statement.object)
          end
        end
      end

      # used by full pipeline, only
      def appropriate_fields
        outbound_predicates = outbound_graph.predicates.to_a
        result = proxy_record.class.properties.select do |_key, value|
          outbound_predicates.include?(value.predicate)
        end
        result.keys
      end

      # used by both pipelines
      def singular_fields
        @singular_fields ||= factory.properties.select { |_att, config| config[:multiple] == false }.keys + ['visibility']
      end

      # used by full pipeline, only
      def cleaned_attributes
        proxy_record.attributes.select do |k, _v|
          appropriate_fields.include?(k)
        end
      end

      # used by abbreviated pipeline, only
      # visibility is not a standard model property, so it is spoofed into the mapping
      def outbound_predicates_to_properties
        @outbound_predicates_to_properties ||=
          outbound_statements.predicates.map { |p| [p, factory.properties.detect { |_key, value| value.predicate == p }&.first] }.to_h.merge(PULTerms.visibility => 'visibility')
      end
  end
end
