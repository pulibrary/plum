class PlumSchema < ActiveTriples::Schema
  property :sort_title, predicate: ::OpaqueMods.titleForSort, multiple: false
  property :portion_note, predicate: ::RDF::Vocab::SKOS.scopeNote, multiple: false
  property :description, predicate: ::RDF::DC.abstract, multiple: false
  property :identifier, predicate: ::RDF::DC.identifier, multiple: false
  property :rights_statement, predicate: ::RDF::Vocab::EDM.rights, multiple: false
  property :rights_note, predicate: ::RDF::Vocab::DC11.rights, multiple: false
  property :source_metadata_identifier, predicate: ::PULTerms.metadata_id, multiple: false
  property :source_metadata, predicate: ::PULTerms.source_metadata, multiple: false
  property :state, predicate: ::F3Access.objState, multiple: false
  property :workflow_note, predicate: ::RDF::Vocab::MODS.note
  property :holding_location, predicate: ::RDF::Vocab::Bibframe.heldBy, multiple: false
  property :ocr_language, predicate: ::PULTerms.ocr_language
end
