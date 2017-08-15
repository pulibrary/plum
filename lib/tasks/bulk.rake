namespace :bulk do
  desc "Ingest a directory of TIFFs as a ScannedResource, or a directory of directories as a MultiVolumeWork"
  task ingest: :environment do
    user = User.find_by_user_key( ENV['USER'] ) if ENV['USER']
    user = User.all.select{ |u| u.admin? }.first unless user
    dir = ENV['DIR']
    bib = ENV['BIB']
    coll = ENV['COLL']
    local_id = ENV['LOCAL_ID']
    replaces = ENV['REPLACES']
    background = ENV['BACKGROUND']
    abort "usage: rake bulk:ingest DIR=/path/to/files BIB=1234567 COLL=collid LOCAL_ID=local_id REPLACES=replaces" unless dir && Dir.exist?(dir)

    coll = ActiveFedora::Base.find(coll) if coll.present?

    @logger = Logger.new(STDOUT)
    @logger.warn "No BIB id specified" unless bib

    @logger.info "ingesting files from: #{dir}"
    @logger.info "ingesting as: #{user.user_key} (override with USER=foo)"
    @logger.info "adding item to collection #{coll.id}" if coll
    begin
      if background
        IngestServiceJob.perform_later(dir, bib, user, collection: coll, local_id: local_id, replaces: replaces)
      else
        IngestService.new(@logger).ingest_dir dir, bib, user, collection: coll, local_id: local_id, replaces: replaces
      end
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
  desc "Attach a set of directories of TIFFs to existing objects, using the directory names as identifiers to find the objects"
  task attach_each_dir: :environment do
    user = User.find_by_user_key( ENV['USER'] ) if ENV['USER']
    user = User.all.select{ |u| u.admin? }.first unless user
    dir = ENV['DIR']
    field = ENV['FIELD']
    filter = ENV['FILTER']
    abort "usage: rake bulk:attach_each_dir DIR=/path/to/files FIELD=barcode FILTER=filter" unless field && dir && Dir.exist?(dir)

    @logger = Logger.new(STDOUT)
    @logger.info "attaching files from: #{dir}"
    @logger.info "attaching as: #{user.user_key} (override with USER=foo)"
    @logger.info "filtering to files ending with #{filter}" if filter
    begin
        IngestService.new(@logger).attach_each_dir dir, field, user, filter
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
    end
  end
end
