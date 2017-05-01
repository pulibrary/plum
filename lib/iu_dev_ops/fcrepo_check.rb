module IuDevOps
  # Performs a Fedora health check by reading the REST API over HTTP.
  # A successful response is considered passing.
  # To implement your own pass/fail criteria, inherit from this
  # class, override #check, and call #perform_request to get the
  # response body.
  include OkComputer
  class FcrepoCheck < HttpCheck
    attr_accessor :auth_options

    # Public: Initialize a new HTTP check.
    #
    # url - The URL to check, may also contain user:pass@ for basic auth but auth_options will override
    # request_timeout - How long to wait to connect before timing out. Defaults to 5 seconds.
    # auth_options - an ordered array containing username then password for :http_basic_authentication
    def initialize(url, request_timeout = 5, auth_options = [])
      super(url, request_timeout)
      self.auth_options = auth_options
    end

    # Public: Return the status of the HTTP check
    def check
      mark_message "HTTP on Fedora REST interface successful" if ping?
    rescue => e
      mark_message "Error: '#{e}'"
      mark_failure
    end

    def basic_auth_options
      if auth_options.any?
        auth_options
      else
        super
      end
    end

    def ping?
      response = perform_request
      !(response =~ %r{info:fedora/fedora-system}).nil?
    end
  end
end
