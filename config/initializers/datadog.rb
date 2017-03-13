require 'net/http'
require 'redis'
require 'ddtrace'

Rails.configuration.datadog_trace = {
  auto_instrument: true,
  auto_instrument_redis: true,
  default_service: "Plum (#{Rails.env})"
}
Datadog::Monkey.patch_all
