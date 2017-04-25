namespace :pmp do
  desc "Purge date_created values"
  task purge_date_created: :environment do |task, args|
    logger = Logger.new(STDOUT)

    begin
      [MultiVolumeWork, ScannedResource].each do |klass|
      logger.info "#{klass.count} #{klass.to_s}(s) found"
      klass.find_each do |resource|
        logger.info "Processing resource: #{resource.id}"
        resource.update_attributes(date_created: nil)
        end
      end
    rescue => e
      logger.info "Error: #{e.message}"
      logger.info e.backtrace
      abort "Error encountered"
    end
  end
end
