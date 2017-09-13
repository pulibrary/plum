require 'rdf'
class PULStore < RDF::StrictVocabulary('http://princeton.edu/pulstore/terms/')
  term :barcode, label: 'Barcode'.freeze, type: 'rdf:Property'.freeze
  term :physicalNumber, label: 'Physical Number'.freeze, type: 'rdf:Property'.freeze
  term :sortOrder, label: 'Sort Order'.freeze, type: 'rdf:Property'.freeze
  term :state, label: 'State'.freeze, type: 'rdf:Property'.freeze
  term :suppressed, label: 'Suppressed'.freeze, type: 'rdf:Property'.freeze
end
