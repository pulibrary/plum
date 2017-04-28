class IIIFPageSchema < ActiveTriples::Schema
  property :viewing_hint, predicate: ::RDF::Vocab::IIIF.viewingHint
end
