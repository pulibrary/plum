namespace :pmp do
  desc "Ingest one or more YAML files"
  task ingest_yaml: :environment do
    user = User.find_by_user_key( ENV['USER'] ) if ENV['USER']
    user = User.all.select{ |u| u.admin? }.first unless user
  
    logger = Logger.new(STDOUT)
    IngestYAMLJob.logger = logger
    logger.info "ingesting .yml files from: #{ARGV[1]}"
    logger.info "ingesting as: #{user.user_key} (override with USER=foo)"
    abort "usage: rake ingest_yaml /path/to/yaml/files" unless ARGV[1] && Dir.exist?(ARGV[1])
    Dir["#{ARGV[1]}/**/*.yml"].each do |file|
      begin
        IngestYAMLJob.perform_now(file, user)
      rescue => e
        puts "Error: #{e.message}"
        puts e.backtrace
      end
    end
  end
end
