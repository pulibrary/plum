# frozen_string_literal: true
class CompositePendingUpload
  def self.create(params, curation_concern_id, upload_set_id)
    params.each do |_index, file_options|
      new(file_options, curation_concern_id, upload_set_id).save
    end
  end

  attr_reader :url, :file_name, :file_size, :upload_set_id, :curation_concern_id

  def initialize(file_options, curation_concern_id, upload_set_id)
    @url = file_options.fetch(:url)
    @file_name = file_options.fetch(:file_name)
    @file_size = file_options.fetch(:file_size)
    @upload_set_id = upload_set_id
    @curation_concern_id = curation_concern_id
  end

  def save
    pending_upload.file_name = file_name
    pending_upload.file_path = file_path
    pending_upload.upload_set_id = upload_set_id
    pending_upload.curation_concern_id = curation_concern_id
    pending_upload.save
  end

  private

    def file_path
      FilePath.new(url).clean
    end

    def pending_upload
      @pending_upload ||= PendingUpload.new
    end
end
