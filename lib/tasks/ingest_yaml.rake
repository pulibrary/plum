namespace :pmp do
  desc "Ingest a YAML file"
  task ingest: :environment do |task, args|
    file = ARGV[1]
    abort "usage: rake pmp:ingest /path/to/yaml_file" unless file
    abort "File not found: #{file}" unless File.exists?(file)
    abort "Directory given instead of file: #{file}" if Dir.exists?(file)

    user = User.find_by_user_key( ENV['USER'] ) if ENV['USER']
    user = User.all.select{ |u| u.admin? }.first unless user

    logger = Logger.new(STDOUT)
    IngestYAMLJob.logger = logger
    logger.info "ingesting file: #{file}"
    logger.info "ingesting as: #{user.user_key} (override with USER=foo)"

    begin
      file_association_method = ENV['FILE_ASSOCIATION_METHOD'] || 'batch'
      logger.info "ingesting with file association method: #{file_association_method} (override with FILE_ASSOCIATION_METHOD=batch|individual|none)"
      IngestYAMLJob.perform_now(file, user, file_association_method: file_association_method)
    rescue => e
      logger.info "Error: #{e.message}"
      logger.info e.backtrace
      abort "Error encountered"
    end
  end
end
