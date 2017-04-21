class EphemeraSchema < ActiveTriples::Schema
  # Administrative
  property :barcode, predicate: ::RDF::URI("http://plum.com/predicates/barCode")
  property :folder_number, predicate: ::RDF::URI("http://plum.com/predicates/folder_number")
  property :genre, predicate: ::RDF::URI("http://plum.com/predicates/genre")
  property :width, predicate: ::RDF::URI("http://plum.com/predicates/width_cm")
  property :height, predicate: ::RDF::URI("http://plum.com/predicates/height_cm")
  property :page_count, predicate: ::RDF::URI("http://plum.com/predicates/pages")

  # Descriptive
  # Language/Title from BasicMetadata
  property :sort_title, predicate: ::RDF::URI("http://plum.com/predicates/sort_title")
  property :alternative_title, predicate: ::RDF::URI("http://plum.com/predicates/alternative_title")
  property :series, predicate: ::RDF::URI("http://plum.com/predicates/series")
  # Creator/Contributor/Publisher from BasicMetadata
  property :geographic_origin, predicate: ::RDF::URI("http://plum.com/predicates/geo_origin")
  # date_created from BasicMetadata
  property :genre, predicate: ::RDF::URI("http://plum.com/predicates/genre")
  # Subject from BasicMetadata
  property :geo_subject, predicate: ::RDF::URI("http://plum.com/predicates/geo_subject")
  # Description from BasicMetadata
end
