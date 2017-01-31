class BrowseEverythingIngestJob < ApplicationJob
  queue_as :default

  def perform(curation_concern_id, upload_set_id, current_user, selected_files)
    curation_concern = ActiveFedora::Base.find(curation_concern_id)
    selected_files.each do |_index, file_info|
      actor = FileSetActor.new(FileSet.new, current_user)
      BrowseEverythingIngester.new(curation_concern, upload_set_id, actor, file_info).save
    end
  end
end
