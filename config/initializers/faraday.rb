Faraday.default_adapter = :net_http_persistent

module Faraday
  class EssError < Faraday::ClientError; end
  class EssUnauthorizedError < Faraday::EssError; end
  class EssServerError < Faraday::EssError; end

  class Response::RaiseEssError < Response::Middleware
    def on_complete(env)
      case env[:status]
      when 400 # Not actually encountered in the wild, but easy to trigger in tests.
        log_error(env)
        raise Faraday::EssError, response_values(env)
      when 401
        log_error(env)
        raise Faraday::EssUnauthorizedError, response_values(env)
      when 500
        log_error(env)
        raise Faraday::EssServerError, response_values(env)
      end
    end

    private

      def log_error(env)
        Rails.logger.warn format('Raising HTTP request error for retry: %s %s %s', env[:method], env[:url].to_s, env[:status])
      end

      def response_values(env)
        { status: env.status, headers: env.response_headers, body: env.body }
      end
  end
end
Faraday::Response.register_middleware raise_ess_error: -> { Faraday::Response::RaiseEssError }

module PumpkinExtensions
  module ActiveFedora
    module Fedora
      module FaradayBlock
        extend ActiveSupport::Concern

        included do
          def authorized_connection
            options = {}
            options[:ssl] = ssl_options if ssl_options
            options[:request] = { timeout: 600 } # Long timeout for slow Fedora requests.
            connection = Faraday.new(host, options) do |conn|
              conn.request :url_encoded # This is a default middleware
              conn.request :retry, max: 4, interval: 0.1, backoff_factor: 4 # Safe retry for timeouts.
              conn.request :retry, max: 4, interval: 0.1, backoff_factor: 4, # Retry all methods that seem to be ESS errors.
                                   methods: [], exceptions: [Faraday::EssError],
                                   retry_if: ->(env, _exception) { env[:status] != 404 } # Should never encounter 404, but just in case.
              conn.request :instrumentation
              conn.response :raise_ess_error
              conn.adapter Faraday.default_adapter
            end
            connection.basic_auth(user, password)
            connection
          end
        end
      end
    end
  end
end
ActiveFedora::Fedora.include PumpkinExtensions::ActiveFedora::Fedora::FaradayBlock

ActiveSupport::Notifications.subscribe('request.faraday') do |_name, starts, ends, _, env|
  duration = ends - starts
  if duration > 0.2
    url = env[:url]
    http_method = env[:method].to_s.upcase
    status = env[:status]
    Rails.logger.info format('Slow request: [%s:%s] %s %s %s (%.3f s)', url.host, url.port, http_method, url.request_uri, status, duration)
  end
end
