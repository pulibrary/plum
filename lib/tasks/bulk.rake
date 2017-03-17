namespace :bulk do
  desc "Ingest a directory of TIFFs as a ScannedResource, or a directory of directories as a MultiVolumeWork"
  task ingest: :environment do
    user = User.find_by_user_key( ENV['USER'] ) if ENV['USER']
    user = User.all.select{ |u| u.admin? }.first unless user
    dir = ENV['DIR']
    bib = ENV['BIB']
    abort "usage: rake bulk:ingest DIR=/path/to/files BIB=1234567" unless bib && dir && Dir.exist?(dir)

    @logger = Logger.new(STDOUT)
    @logger.info "ingesting files from: #{dir}"
    @logger.info "ingesting as: #{user.user_key} (override with USER=foo)"
    begin
      IngestService.new(@logger).ingest_dir dir, bib, user
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
    end
  end
  desc "Ingest a directory of scanned map TIFFs, each filename corresponds to a Bib ID"
  task ingest_scanned_maps: :environment do
    user = User.find_by_user_key( ENV['USER'] ) if ENV['USER']
    user = User.all.select{ |u| u.admin? }.first unless user
    dir = ENV['DIR']

    abort "usage: rake bulk:ingest_scanned_maps DIR=/path/to/files" unless dir && Dir.exist?(dir)

    @logger = Logger.new(STDOUT)
    @logger.info "ingesting files from: #{dir}"
    @logger.info "ingesting as: #{user.user_key} (override with USER=foo)"
    begin
      IngestScannedMapsService.new(@logger).ingest_dir dir, user
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
    end
  end
end
