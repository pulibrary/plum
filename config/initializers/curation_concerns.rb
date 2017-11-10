CurationConcerns.configure do |config|
  # Injected via `rails g curation_concerns:work MultiVolumeWork`
  config.register_curation_concern :multi_volume_work
  # Injected via `rails g curation_concerns:work ScannedResource`
  config.register_curation_concern :scanned_resource

  config.max_days_between_audits = 7

  # Enable displaying usage statistics in the UI
  # Defaults to FALSE
  # Requires a Google Analytics id and OAuth2 keyfile.  See README for more info
  config.analytics = false

  # Specify a Google Analytics tracking ID to gather usage statistics
  # config.google_analytics_id = 'UA-99999999-1'

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # config.analytic_start_date = DateTime.new(2014,9,10)

  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  # config.temp_file_base = '/home/developer1'

  # Specify the form of hostpath to be used in Endnote exports
  # config.persistent_hostpath = 'http://localhost/files/'

  # Location on local file system where derivatives will be stored.
  config.derivatives_path = ENV["PMP_DERIVATIVES_PATH"] || File.join(Rails.root, 'tmp', 'derivatives')

  # If you have ffmpeg installed and want to transcode audio and video uncomment this line
  # config.enable_ffmpeg = true

  # CurationConcerns uses NOIDs for files and collections instead of Fedora UUIDs
  # where NOID = 10-character string and UUID = 32-character string w/ hyphens
  # config.enable_noids = true

  # Specify a different template for your repository's NOID IDs
  config.noid_template = ENV["PMP_NOID_TEMPLATE"] || "#{Rails.env.first.downcase}.reeddeeddk"

  # Specify the minter statefile
  config.minter_statefile = "log/minter-state-#{Rails.env}"

  # Specify the prefix for Redis keys:
  # config.redis_namespace = "curation_concerns"

  # Specify the path to the file characterization tool:
  # config.fits_path = "fits.sh"

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # Leaving it blank will set the start date to when ever the file was uploaded by
  # NOTE: if you have always sent analytics to GA for downloads and page views leave this commented out
  # config.analytic_start_date = DateTime.new(2014,9,10)
  config.working_path = ENV["PMP_UPLOAD_PATH"]

  # Set TTL in milliseconds of object locks:
  config.lock_time_to_live = 600_000 # 10m because we have long running jobs
  # Disable retrying to attain a lock because the UI should not retry.
  config.lock_retry_count = 1

  ## Whitelist all directories which can be used to ingest from the local file
  # system.
  #
  # Any file, and only those, that is anywhere under one of the specified
  # directories can be used by CreateWithRemoteFilesActor to add local files
  # to works. Files uploaded by the user are handled separately and the
  # temporary directory for those need not be included here.
  #
  # Default value includes BrowseEverything.config['file_system'][:home] if it
  # is set, otherwise default is an empty list. You should only need to change
  # this if you have custom ingestions using CreateWithRemoteFilesActor to
  # ingest files from the file system that are not part of the BrowseEverything
  # mount point.
  #
  config.class_eval do
    attr_writer :whitelisted_ingest_dirs

    def whitelisted_ingest_dirs
      if defined? BrowseEverything
        Array.wrap(BrowseEverything.config['file_system'].try(:[], :home)).compact
      else
        []
      end
    end
  end

  # config.whitelisted_ingest_dirs = []
end

Date::DATE_FORMATS[:standard] = '%m/%d/%Y'
