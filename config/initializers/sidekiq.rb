require_relative 'redis_config'
Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 100) { Redis.current }
end

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 20) { Redis.current }
end
