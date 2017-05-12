namespace :bulk do
  desc "Ingest maps sets from JSON file"
  task ingest_map_sets: :environment do
    user = User.find_by_user_key( ENV['USER'] ) if ENV['USER']
    user = User.all.select{ |u| u.admin? }.first unless user
    json_file = ENV['JSON']
    tiff_dir = ENV['TIFF']
    background = ENV['BACKGROUND']
    abort "usage: rake bulk:ingest_existing_scanned_maps JSON=/path/to/json TIFFS=/path/to/tiffs/" unless json_file && File.exist?(json_file)

    map_set_records = JSON.parse(File.read(json_file))

    @logger = Logger.new(STDOUT)
    @logger.info "ingesting as: #{user.user_key} (override with USER=foo)"
    map_set_records.each do |record|  
      begin
        if background
          IngestMapSetJob.perform_later(record, tiff_dir, user)
        else
          IngestMapSetService.new(@logger).ingest_map_set(record, tiff_dir, user)
        end
      rescue => e
        puts "Error: #{e.message}"
        puts e.backtrace
      end
    end
  end
end
