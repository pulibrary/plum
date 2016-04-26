require 'rdf'
class PULTerms < RDF::StrictVocabulary('http://library.princeton.edu/terms/')
  term :exhibit_id, label: 'Exhibit ID'.freeze, type: 'rdf:Property'.freeze
  term :metadata_id, label: 'Metadata ID'.freeze, type: 'rdf:Property'.freeze
  term :source_metadata, label: 'Source Metadata'.freeze, type: 'rdf:Property'.freeze
  term :ocr_language, label: "OCR Language".freeze, type: 'rdf:Property'.freeze
  term :pdf_type, label: "PDF Type".freeze, type: 'rdf:Property'.freeze
end
