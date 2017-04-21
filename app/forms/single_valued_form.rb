class SingleValuedForm < Hyrax::Forms::WorkForm
  class_attribute :single_valued_fields
  self.single_valued_fields = []

  def self.multiple?(field)
    if single_valued_fields.include?(field.to_sym)
      false
    else
      super
    end
  end

  def self.model_attributes(form_params)
    super.tap do |params|
      single_valued_fields.each do |field|
        params[field.to_s] = Array.wrap(params[field.to_s])
      end
    end
  end

  def multiple?(field)
    if single_valued_fields.include?(field.to_sym)
      false
    else
      super
    end
  end

  def [](key)
    return super.first if single_valued_fields.include?(key.to_sym)
    super
  end
end
