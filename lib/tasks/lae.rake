# frozen_string_literal: true
namespace :lae do
  desc "Ingest one or more LAE folders"
  task ingest: :environment do
    user = User.find_by_user_key(ENV['USER']) if ENV['USER']
    user = User.all.select(&:admin?).first unless user
    folder_dir = ARGV[1]
    project = ENV['PROJECT']

    puts "Ingesting ephemera folder #{folder_dir}"
    puts "Ingesting as: #{user.user_key} (override with USER=foo)"
    abort "usage: rake lae:ingest /path/to/lae/folder" unless Dir.exist?(folder_dir)
    IngestEphemeraService.new(folder_dir, user, project).ingest
  end
end
