class GeoSchema < ActiveTriples::Schema
  property :identifier, predicate: ::RDF::Vocab::DC.identifier, multiple: false
  property :sort_title, predicate: ::OpaqueMods.titleForSort, multiple: false
  property :replaces, predicate: ::RDF::Vocab::DC.replaces, multiple: false
  property :rights_statement, predicate: ::RDF::Vocab::EDM.rights, multiple: false
  property :rights_note, predicate: ::RDF::Vocab::DC11.rights, multiple: false
  property :source_metadata_identifier, predicate: ::PULTerms.metadata_id, multiple: false
  property :source_metadata, predicate: ::PULTerms.source_metadata, multiple: false
  property :holding_location, predicate: ::RDF::Vocab::Bibframe.heldBy, multiple: false
  property :ocr_language, predicate: ::PULTerms.ocr_language
end
