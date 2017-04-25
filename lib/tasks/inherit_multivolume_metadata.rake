# Inherit most ingested metadata, exempting identifier, title, and sort_title
namespace :pmp do
  desc "Inherit MultiVolumeWork library metadata onto members"
  task inherit_multivolume_metadata: :environment do |task, args|
    logger = Logger.new(STDOUT)

    begin
      logger.info "#{MultiVolumeWork.count} MultiVolumeWork(s) found"
      MultiVolumeWork.find_each do |parent|
        logger.info "Processing MultiVolumeWork: #{parent.id}"
        children = parent.members
        logger.info "#{children.size} children found"
        children.each do |child|
          logger.info "Processing ScannedResource: #{child.id}"
          [:source_metadata_identifier, :holding_location, :physical_description, :copyright_holder, :responsibility_note, :series, :creator, :subject, :date_created, :publisher, :publication_place, :date_published, :published, :lccn_call_number, :local_call_number].each do |att|
            child.send("#{att}=", parent.send(att).dup)
          end
          child.save!
        end
      end
    rescue => e
      logger.info "Error: #{e.message}"
      logger.info e.backtrace
      abort "Error encountered"
    end
  end
end
