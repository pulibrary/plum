require 'rdf'
class PULTerms < RDF::StrictVocabulary('http://library.princeton.edu/terms/')
  term :metadata_id, label: 'Metadata ID'.freeze, type: 'rdf:Property'.freeze
  term :source_metadata, label: 'Source Metadata'.freeze, type: 'rdf:Property'.freeze
end
