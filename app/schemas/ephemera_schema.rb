class EphemeraSchema < ActiveTriples::Schema
  # Administrative
  property :barcode, predicate: ::RDF::Vocab::DC.identifier
  property :folder_number, predicate: ::RDF::RDFS.label
  property :width, predicate: ::RDF::Vocab::SCHEMA.width
  property :height, predicate: ::RDF::Vocab::SCHEMA.height
  property :page_count, predicate: ::RDF::Vocab::NFO.pageCount

  # Descriptive
  # Language/Title from BasicMetadata
  property :sort_title, predicate: ::OpaqueMods.titleForSort
  property :alternative_title, predicate: ::RDF::Vocab::DC.alternative
  property :series, predicate: ::PULTerms.seriesTitle
  # Creator/Contributor/Publisher from BasicMetadata
  property :geographic_origin, predicate: ::RDF::Vocab::BF2.originPlace
  # date_created from BasicMetadata
  property :genre, predicate: ::RDF::Vocab::DC.type
  # Subject from BasicMetadata
  property :geo_subject, predicate: ::RDF::Vocab::DC.coverage
  # Description from BasicMetadata
end
