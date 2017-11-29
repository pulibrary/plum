# frozen_string_literal: true
module RDF
  class Literal
    def as_json(*_args)
      JSON::LD::API.fromRdf([RDF::Statement.new(RDF::URI(""), RDF::URI(""), value)])[0][""][0]
    end
  end
end
