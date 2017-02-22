Hyrax.config do |config|
  # Injected via `rails g hyrax:work MultiVolumeWork`
  config.register_curation_concern :multi_volume_work
  # Injected via `rails g hyrax:work ScannedResource`
  config.register_curation_concern :scanned_resource
  # Injected via `rails g geo_concerns:install`
  config.register_curation_concern :vector_work
  config.register_curation_concern :raster_work
  config.register_curation_concern :image_work

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
  # config.derivatives_path = File.join(Rails.root, 'tmp', 'derivatives')

  # If you have ffmpeg installed and want to transcode audio and video uncomment this line
  # config.enable_ffmpeg = true

  # Hyrax uses NOIDs for files and collections instead of Fedora UUIDs
  # where NOID = 10-character string and UUID = 32-character string w/ hyphens
  # config.enable_noids = true

  # Specify a different template for your repository's NOID IDs
  config.noid_template = "#{Rails.env.first.downcase}.reeddeeddk"

  # Specify the minter statefile
  config.minter_statefile = "log/minter-state-#{Rails.env}"

  # Specify the prefix for Redis keys:
  # config.redis_namespace = "hyrax"

  # Specify the path to the file characterization tool:
  # config.fits_path = "fits.sh"

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # Leaving it blank will set the start date to when ever the file was uploaded by
  # NOTE: if you have always sent analytics to GA for downloads and page views leave this commented out
  # config.analytic_start_date = DateTime.new(2014,9,10)
  config.working_path = ENV["PLUM_UPLOAD_PATH"]
  config.work_requires_files = false
  config.active_deposit_agreement_acceptance = false
end

Date::DATE_FORMATS[:standard] = '%m/%d/%Y'
Hyrax::Workflow::WorkflowFactory.workflow_strategy = Workflow::PlumWorkflowStrategy
Hyrax::MemberPresenterFactory.work_presenter_class = DynamicShowPresenter.new
Hyrax::MemberPresenterFactory.file_presenter_class = FileSetPresenter
# Prepend our derivative service.
Hyrax::DerivativeService.services = [PlumDerivativesService, GeoWorks::FileSetDerivativesService] + Hyrax::DerivativeService.services
