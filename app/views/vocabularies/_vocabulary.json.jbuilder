# frozen_string_literal: true
json.extract! vocabulary, :id, :label, :created_at, :updated_at
json.url vocabulary_url(vocabulary, format: :json)
