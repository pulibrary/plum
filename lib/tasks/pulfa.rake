# frozen_string_literal: true
namespace :pulfa do
  desc "Ingest a PULFA METS file"
  task ingest: :environment do
    user = User.find_by_user_key(ENV['USER']) if ENV['USER']
    user = User.all.select(&:admin?).first unless user

    logger = Logger.new(STDOUT)
    IngestPULFAJob.logger = logger

    dir = ENV['METS_DIR']
    logger.info "ingesting pulfa mets files from: #{dir}"
    logger.info "ingesting as: #{user.user_key} (override with USER=foo)"
    abort "usage: rake pulfa:ingest METS_DIR=/path/to/mets/files" unless dir && Dir.exist?(dir)

    Dir["#{dir}/**/*.mets"].each do |file|
      begin
        IngestPULFAJob.perform_later(file, user)
      rescue => e
        puts "Error: #{e.message}"
        puts e.backtrace
      end
    end
  end
end
