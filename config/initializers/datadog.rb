# frozen_string_literal: true
require 'net/http'
require 'redis'

if Rails.env.staging? || Rails.env.production?
  require 'ddtrace'
  Rails.configuration.datadog_trace = {
    auto_instrument: true,
    auto_instrument_redis: true,
    default_service: "Plum (#{Rails.env})"
  }
  Datadog::Monkey.patch_all
end
