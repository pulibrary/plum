class RunOCRJob < ActiveJob::Base
  queue_as :lowest

  def perform(file_set_id, filename = nil)
    file_set = FileSet.find(file_set_id)
    OCRRunner.new(file_set).from_file((filename || file_set.local_file))
    file_set.save
  end
end
