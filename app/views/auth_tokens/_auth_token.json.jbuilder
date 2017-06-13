json.extract! auth_token, :id, :created_at, :updated_at
json.url auth_token_url(auth_token, format: :json)
