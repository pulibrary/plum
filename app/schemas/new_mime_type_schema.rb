class NewMimeTypeSchema < ActiveTriples::Schema
  property :mime_type_storage, predicate: RDF::URI.new("http://test.com/mimeType")
end
