class DisplayableSchema < ActiveTriples::Schema
  property :source_metadata, predicate: ::PULTerms.source_metadata, multiple: false
end
