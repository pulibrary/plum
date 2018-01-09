# frozen_string_literal: true
require 'rdf'
class OpaqueMods < RDF::StrictVocabulary('http://opaquenamespace.org/ns/mods/')
  term :titleForSort, label: 'Title for Sort', type: 'rdf:Property'
end
