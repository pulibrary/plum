# frozen_string_literal: true
require 'rest-client'

class JSONLDRecord
  class Factory
    attr_reader :factory
    def initialize(factory)
      @factory = factory
    end

    def retrieve(bib_id)
      marc = PulMetadataServices::Client.retrieve(bib_id)
      raise MissingRemoteRecordError if marc.source.end_with?("not found or suppressed")
      JSONLDRecord.new(bib_id, marc.source, factory: factory)
    end
  end

  class MissingRemoteRecordError < StandardError; end

  attr_reader :bib_id, :marc, :factory
  def initialize(bib_id, marc, factory: ScannedResource)
    @bib_id = bib_id
    @marc = marc
    @factory = factory
  end

  def source
    marc
  end

  def jsonld
    @jsonld ||= RestClient.get("https://bibdata.princeton.edu/bibliographic/#{bib_id}/jsonld")
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

    @attributes
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
      @outbound_graph ||= RDF::Graph.new.from_jsonld(jsonld)
    end
end
