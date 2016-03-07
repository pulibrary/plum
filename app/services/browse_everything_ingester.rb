class BrowseEverythingIngester
  attr_reader :curation_concern, :upload_set_id, :actor, :file_info
  delegate :mime_type, :file_name, :file_path, to: :file_info
  def initialize(curation_concern, upload_set_id, actor, file_info)
    @curation_concern = curation_concern
    @upload_set_id = upload_set_id
    @actor = actor
    @file_info = FileInfo.new(file_info.to_h)
  end

  def save
    actor.create_metadata(curation_concern, {})
    actor.create_content(decorated_file)
    cleanup_download
  end

  private

    def file
      @file ||= File.open(downloaded_file_path)
    end

    def decorated_file
      @decorated_file ||= IoDecorator.new(file, mime_type, file_name)
    end

    def retriever
      @retriever ||= BrowseEverything::Retriever.new
    end

    def downloaded_file_path
      @downloaded_file_path ||= retriever.download(file_info)
    end

    def cleanup_download
      File.delete(file.path)
    end
end
