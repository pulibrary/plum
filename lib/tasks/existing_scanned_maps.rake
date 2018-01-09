# frozen_string_literal: true
namespace :bulk do
  desc "Ingest existing scanned map TIFFs from a CSV file"
  task ingest_existing_scanned_maps: :environment do
    user = User.find_by_user_key(ENV['USER']) if ENV['USER']
    user = User.all.select(&:admin?).first unless user
    csv_file = ENV['CSV']
    tiff_dir = ENV['TIFF']
    background = ENV['BACKGROUND']
    abort "usage: rake bulk:ingest_existing_scanned_maps CSV=/path/to/csv TIFFS=/path/to/tiffs/" unless csv_file && File.exist?(csv_file)

    csv = CSV.parse(File.open(csv_file, 'r'))
    fields = csv.shift
    records = csv.collect { |record| Hash[*fields.zip(record).flatten] }

    @logger = Logger.new(STDOUT)
    @logger.info "ingesting as: #{user.user_key} (override with USER=foo)"
    records.each do |record|
      begin
        path = path_to_tiff(tiff_dir, record.fetch('ark'))
        if background
          IngestExistingScannedMapJob.perform_later(record, path, user)
        else
          IngestExistingScannedMap.new(@logger).ingest_map_record(record, path, user)
        end
      rescue => e
        puts "Error: #{e.message}"
        puts e.backtrace
      end
    end
  end
end

def path_to_tiff(base_dir, noid)
  path = ''
  noid.scan(/.{1,2}/).each { |seg| path << '/' + seg }
  "#{base_dir}#{path}/#{noid}.tif"
end
