class RedisConfig
  class << self
    def url
      "redis://#{config[:host] || 'localhost'}:#{config[:port] || 6379}"
    end

    def namespace
      config[:namespace]
    end

    def config
      @config ||= YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
    end
  end
end
Sidekiq.configure_server do |config|
  config.redis = { url: RedisConfig.url, namespace: RedisConfig.namespace }
end

Sidekiq.configure_client do |config|
  config.redis = { url: RedisConfig.url, namespace: RedisConfig.namespace }
end
