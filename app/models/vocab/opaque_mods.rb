require 'rdf'
class OpaqueMods < RDF::StrictVocabulary('http://opaquenamespace.org/ns/mods/')
  term :titleForSort, label: 'Title for Sort'.freeze, type: 'rdf:Property'.freeze
end
