# If PMP_OK_URL set, then OkComputer will mount a route at that location, otherwise it is effectively disabled
OkComputer.mount_at = ENV["PMP_OK_URL"] || false

OkComputer.require_authentication(ENV["PMP_OK_USER"], ENV["PMP_OK_PASS"]) unless ENV["PMP_OK_USER"].blank?

# For built-in checks, see https://github.com/sportngin/okcomputer/tree/master/lib/ok_computer/built_in_checks

# Following checks execute after full initialization so that backend configuration values are available
Rails.application.configure do
  config.after_initialize do
    checks = OkComputer::CheckCollection.new("Standard Checks")
    OkComputer::Registry.register "default", checks

    checks.register "rails", OkComputer::DefaultCheck.new
    checks.register "database", OkComputer::ActiveRecordCheck.new

    redis_url = Redis.current.client.options[:host]
    redis_port = Redis.current.client.options[:port]
    checks.register "redis", OkComputer::RedisCheck.new(host: redis_url, port: redis_port)

    checks.register "ruby", OkComputer::RubyVersionCheck.new

    checks.register "cache", OkComputer::GenericCacheCheck.new

    iiif_url = Plum.config[:iiif_url]
    checks.register "iiif", OkComputer::HttpCheck.new(iiif_url)

    solr_url = ActiveFedora.solr_config[:url]
    checks.register "solr", OkComputer::SolrCheck.new(solr_url)

    fcrepo_url = ActiveFedora.fedora_config.credentials[:url]
    fedora_user = ActiveFedora.fedora_config.credentials[:user]
    fedora_password = ActiveFedora.fedora_config.credentials[:password]
    auth_options = [fedora_user, fedora_password]
    checks.register "fcrepo", IuDevOps::FcrepoCheck.new(fcrepo_url, 10, auth_options)

    # TODO: Remove this when CheckCollection instances not setting registrant_name is fixed.
    checks.collection.each do |check_name, check_obj|
      check_obj.registrant_name = check_name
    end
  end
end
