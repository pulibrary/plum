class CollectionEditForm < CurationConcerns::Forms::CollectionEditForm
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

  def description
    self[:description].first
  end
end
