class CollectionEditForm < Hyrax::Forms::CollectionForm
  terms << :exhibit_id
  delegate :exhibit_id, to: :model

  def self.model_attributes(attrs)
    attrs[:title] = Array(attrs[:title]) if attrs[:title]
    attrs[:description] = Array(attrs[:description]) if attrs[:description]
    super(attrs)
  end

  def initialize_fields
    super
  end

  def title
    self[:title].first
  end

  def primary_terms
    [:title, :exhibit_id, :description]
  end

  def secondary_terms
    []
  end
end
