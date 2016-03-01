class CollectionEditForm < CurationConcerns::Forms::CollectionEditForm
  terms << :exhibit_id
  delegate :exhibit_id, to: :model

  def self.model_attributes(attrs)
    attrs[:title] = Array(attrs[:title]).first if attrs[:title]
    attrs[:description] = Array(attrs[:description]).first if attrs[:description]
    super(attrs)
  end
end
