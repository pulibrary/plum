class JSONLDRecord
  extend Forwardable
  class Factory
    attr_reader :factory
    def initialize(factory)
      @factory = factory
    end

    def retrieve(bib_id)
      marc = IuMetadata::Client.retrieve(bib_id, :marc)
      mods = IuMetadata::Client.retrieve(bib_id, :mods)
      raise MissingRemoteRecordError, 'Missing MARC record' if marc.source.blank?
      raise MissingRemoteRecordError, 'Missing MODS record' if mods.source.blank?
      JSONLDRecord.new(bib_id, marc, mods, factory: factory)
    end
  end

  class MissingRemoteRecordError < StandardError; end

  attr_reader :bib_id, :marc, :mods, :factory
  def initialize(bib_id, marc, mods, factory: ScannedResource)
    @bib_id = bib_id
    @marc = marc
    @mods = mods
    @factory = factory
  end

  def source
    marc_source
  end

  def_delegator :@marc, :source, :marc_source
  def_delegator :@mods, :source, :mods_source

  def attributes
    @attributes ||=
      begin
        Hash[
          cleaned_attributes.map do |k, _|
            [k, proxy_record.get_values(k, literal: true)]
          end
        ]
      end
  end

  def appropriate_fields
    outbound_predicates = outbound_graph.predicates.to_a
    result = proxy_record.class.properties.select do |_key, value|
      outbound_predicates.include?(value.predicate)
    end
    result.keys
  end

  private

    def proxy_record
      @proxy_record ||= factory.new.tap do |resource|
        outbound_graph.each do |statement|
          resource.resource << RDF::Statement.new(resource.rdf_subject, statement.predicate, statement.object)
        end
      end
    end

    def cleaned_attributes
      proxy_record.attributes.select do |k, _v|
        appropriate_fields.include?(k)
      end
    end

    def outbound_graph
      @outbound_graph ||= generate_outbound_graph
    end

    CONTEXT = YAML.load(File.read('config/context.yml'))

    def generate_outbound_graph
      jsonld_hash = {}
      jsonld_hash['@context'] = CONTEXT["@context"]
      jsonld_hash['@id'] = marc.id
      jsonld_hash.merge!(marc.attributes.stringify_keys)
      outbound_graph = RDF::Graph.new << JSON::LD::API.toRdf(jsonld_hash)
      outbound_graph
    end
end
