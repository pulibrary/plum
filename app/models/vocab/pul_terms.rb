# frozen_string_literal: true
require 'rdf'
class PULTerms < RDF::StrictVocabulary('http://library.princeton.edu/terms/')
  term :exhibit_id, label: 'Exhibit ID', type: 'rdf:Property'
  term :metadata_id, label: 'Metadata ID', type: 'rdf:Property'
  term :source_metadata, label: 'Source Metadata', type: 'rdf:Property'
  term :source_jsonld, label: 'Source JSON-LD', type: 'rdf:Property'
  term :ocr_language, label: "OCR Language", type: 'rdf:Property'
  term :pdf_type, label: "PDF Type", type: 'rdf:Property'
  term :call_number, label: "Call Number", type: 'rdf:Property'
  term :container, label: "Container", type: 'rdf:Property'
  term :seriesTitle, label: 'Series Title', type: 'rdf:Property'
  term :barcode, label: 'Barcode', type: 'rdf:Property'
  term :ephemera_project, label: 'Ephemera Project', type: 'rdf:Property'
  term :shipped_date, label: 'Shipped Date', type: 'rdf:Property'
  term :tracking_number, label: 'Tracking Number', type: 'rdf:Property'
end
