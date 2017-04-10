json.extract! vocabulary_collection, :id, :label, :created_at, :updated_at
json.url vocabulary_collection_url(vocabulary_collection, format: :json)
json.member VocabularyTerm.where(vocabulary_collection_id: @vocabulary_collection.id).map { |term| vocabulary_term_url(term, format: :json) }
json.inScheme vocabulary_url(@vocabulary_collection.vocabulary, format: :json)
