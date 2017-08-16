namespace :mets do
  desc "Ingest one or more METS files"
  task ingest: :environment do
    user = User.find_by_user_key( ENV['USER'] ) if ENV['USER']
    user = User.all.select{ |u| u.admin? }.first unless user

    logger = Logger.new(STDOUT)
    IngestMETSJob.logger = logger
    logger.info "ingesting mets files from: #{ARGV[1]}"
    logger.info "ingesting as: #{user.user_key} (override with USER=foo)"
    abort "usage: rake mets:ingest /path/to/mets/files" unless ARGV[1] && Dir.exist?(ARGV[1])
    Dir["#{ARGV[1]}/**/*.mets"].each do |file|
      begin
        background = ENV['BACKGROUND']
        if background
          IngestMETSJob.perform_later(file, user)
        else
          IngestMETSJob.perform_now(file, user)
        end
      rescue => e
        puts "Error: #{e.message}"
        puts e.backtrace
      end
    end
  end

  desc "Validate one or more METS files"
  task validate: :environment do
    logger = Logger.new(STDOUT)
    ValidateIngestJob.logger = logger
    logger.info "validating mets files from: #{ARGV[1]}"
    abort "usage: rake mets:validate /path/to/mets/files" unless ARGV[1] && Dir.exist?(ARGV[1])
    Dir["#{ARGV[1]}/**/*.mets"].each do |file|
      begin
        ValidateIngestJob.perform_now(file)
      rescue => e
        puts "Error: #{e.message}"
        puts e.backtrace
      end
    end
  end
end
