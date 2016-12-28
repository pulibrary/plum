# Be sure to restart your server when you modify this file.

if Rails.env == 'production'
  Rails.application.config.session_store :mem_cache_store, key: '_pages_session'
else
  Rails.application.config.session_store :cookie_store, key: '_pages_session'
end
