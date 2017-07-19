class BrowseEverythingIngestJob < ActiveJob::Base
  queue_as :default

  def perform(curation_concern_id, upload_set_id, current_user, selected_files)
    curation_concern = ActiveFedora::Base.find(curation_concern_id)
    actors = selected_files.map do |_index, file_info|
      actor = FileSetActor.new(FileSet.new, current_user)
      BrowseEverythingIngester.new(curation_concern, upload_set_id, actor, file_info).save
      curation_concern.pending_uploads.where(file_name: file_info["file_name"]).delete_all
      actor
    end
    MembershipBuilder.new(curation_concern, actors.map(&:file_set)).attach_files_to_work if actors.any?
  end
end
