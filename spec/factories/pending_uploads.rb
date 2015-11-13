FactoryGirl.define do
  factory :pending_upload do
    curation_concern_id 1
    upload_set_id 1
    file_name "Test.tiff"
    file_path "/Test/Path/Test.tiff"
  end
end
