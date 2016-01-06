class CollectionEditForm < CurationConcerns::Forms::CollectionEditForm
  terms << :exhibit_id
  delegate :exhibit_id, to: :model
end
