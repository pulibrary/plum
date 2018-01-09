# frozen_string_literal: true
json.extract! vocabulary_term, :id, :label, :uri, :code, :tgm_label, :lcsh_label, :created_at, :updated_at
json.url vocabulary_term_url(vocabulary_term, format: :json)
json.inScheme vocabulary_url(@vocabulary_term.vocabulary, format: :json)
