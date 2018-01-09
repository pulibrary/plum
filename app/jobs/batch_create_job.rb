# frozen_string_literal: true
class BatchCreateJob < ActiveJob::Base
  queue_as Hyrax.config.ingest_queue_name

  def perform(user, uploaded_files, attributes)
    model = attributes.delete(:model) || attributes.delete('model')
    raise ArgumentError, 'attributes must include "model" => ClassName.to_s' unless model
    create(user, uploaded_files, model)
  end

  private

    def create(user, uploaded_files, model)
      uploaded_files.each do |upload_id|
        IngestWorkFromFileJob.perform_later(user, file_path(upload_id), model)
      end
    end

    # return file path unless upload_id is an integer
    def file_path(upload_id)
      return process_file_path(upload_id) unless /^\d+$/i.match(upload_id)
      Hyrax::UploadedFile.find(upload_id).file.path
    end

    def process_file_path(path)
      path.gsub('file://', '')
    end
end
