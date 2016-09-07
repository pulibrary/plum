class JSONLDRecord
  class Factory
    attr_reader :factory
    def initialize(factory)
      @factory = factory
    end

    def retrieve(bib_id)
      marc = IuMetadata::Client.retrieve(bib_id, format: :marc)
      mods = IuMetadata::Client.retrieve(bib_id, format: :mods)
      raise MissingRemoteRecordError, 'Missing MARC record' if marc.source.blank?
      raise MissingRemoteRecordError, 'Missing MODS record' if mods.source.blank?
      JSONLDRecord.new(bib_id, marc.source, mods.source, factory: factory)
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

  def marc_source
    marc
  end

  def mods_source
    mods
  end

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
      #TODO Convert MODS/MARC to JSON-LD instead of using json service
      @outbound_graph ||= RDF::Graph.load("https://bibdata.princeton.edu/bibliographic/#{bib_id}/jsonld") # FIXME: find IU equivalent link
    end
end
