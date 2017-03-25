class CollectionEditForm < Hyrax::Forms::CollectionForm
  terms << :exhibit_id
  delegate :exhibit_id, to: :model

  def self.model_attributes(attrs)
    attrs[:title] = Array(attrs[:title]) if attrs[:title]
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

  def multiple?(field)
    case field.to_sym
    when :description, :title
      return false
    else
      super
    end
  end
end
