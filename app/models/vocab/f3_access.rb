require 'rdf'
class F3Access < RDF::StrictVocabulary('http://fedora.info/definitions/1/0/access/ObjState#')
  term :objState, label: 'Object State'.freeze, type: 'rdf:Property'.freeze
end
