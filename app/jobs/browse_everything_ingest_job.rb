class BrowseEverythingIngestJob < ApplicationJob
  queue_as :default

  def perform(curation_concern_id, upload_set_id, current_user, selected_files)
    curation_concern = ActiveFedora::Base.find(curation_concern_id)
    selected_files.map do |_index, file_info|
      pending_upload = curation_concern.pending_uploads.where(file_path: FilePath.new(file_info["url"]).clean, upload_set_id: upload_set_id).first
      next if pending_upload.fileset_id.present?
      actor = FileSetActor.new(FileSet.new, current_user)
      BrowseEverythingIngester.new(curation_concern, upload_set_id, actor, file_info).save
      pending_upload.update(fileset_id: actor.file_set.id)
    end
    relevant_uploads = selected_files.values.map do |file|
      curation_concern.pending_uploads.where(file_path: FilePath.new(file["url"]).clean, upload_set_id: upload_set_id).first
    end
    records = relevant_uploads.map do |upload|
      FileSet.find(upload.fileset_id)
    end
    relevant_uploads.each(&:destroy)
    curation_concern.ordered_members.concat records
    curation_concern.thumbnail = records.first unless curation_concern.thumbnail_id.present?
    curation_concern.representative = records.first unless curation_concern.representative_id.present?
    curation_concern.save
  end
end
