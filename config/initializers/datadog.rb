require 'net/http'
require 'redis'

if Rails.env.staging? || Rails.env.production?
  require 'sidekiq'
  require 'ddtrace'
  require 'ddtrace/contrib/sidekiq/tracer'
  Rails.configuration.datadog_trace = {
    auto_instrument: true,
    auto_instrument_redis: true,
    default_service: "Plum (#{Rails.env})"
  }

  Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.add(
        Datadog::Contrib::Sidekiq::Tracer,
        sidekiq_service: 'sidekiq'
      )
    end
  end
  Datadog::Monkey.patch_all
end
