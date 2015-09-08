class IIIFBookSchema < ActiveTriples::Schema
  property :viewing_direction, predicate: ::RDF::Vocab::IIIF.viewingDirection, multiple: false
  property :viewing_hint, predicate: ::RDF::Vocab::IIIF.viewingHint, multiple: false
end
