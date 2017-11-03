class SaveStructureJob < ActiveJob::Base
  prepend ::LockableJob
  queue_as :default

  def perform(curation_concern, structure)
    return unless curation_concern.respond_to?(:logical_order)
    # Remove existing logical order object to avoid accumulation of fragments.
    curation_concern.logical_order.destroy eradicate: true
    curation_concern.reload
    curation_concern.logical_order.order = structure
    curation_concern.save
    raise ActiveFedora::RecordNotSaved, "#{curation_concern.id} logical order not saved!" if !curation_concern.persisted? || !curation_concern.logical_order.persisted?
  rescue
    Rails.logger.error "SaveStructureJob failed on #{curation_concern.id}! Following structure may not be persisted:\n#{structure}"
    raise
  end
end
