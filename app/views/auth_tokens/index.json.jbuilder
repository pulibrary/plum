# frozen_string_literal: true
json.array! @auth_tokens, partial: 'auth_tokens/auth_token', as: :auth_token
