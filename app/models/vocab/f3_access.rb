# frozen_string_literal: true
require 'rdf'
class F3Access < RDF::StrictVocabulary('http://fedora.info/definitions/1/0/access/ObjState#')
  term :objState, label: 'Object State', type: 'rdf:Property'
end
