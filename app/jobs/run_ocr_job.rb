class RunOCRJob < ActiveJob::Base
  queue_as :default

  def perform(file_set_id)
    file_set = FileSet.find(file_set_id)
    OCRRunner.new(file_set).from_datastream
  end
end
