desc "Update Voyager Data"
task update_bib_ids: :environment do
  if defined?(Rails) && (Rails.env == 'development')
    Rails.logger = Logger.new(STDOUT)
  end
  VoyagerUpdater::EventStream.new("https://bibdata.princeton.edu/events.json").process!
end
