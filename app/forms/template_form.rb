class TemplateForm < SimpleDelegator
  attr_reader :form, :model
  delegate :to_model, :persisted?, :template_label, to: :model
  delegate :required?, to: :form
  def initialize(model, form)
    @model = model
    @form = form
    super(form)
  end

  def member_of_collection_ids
    model.params[:member_of_collection_ids]
  end

  def required?(_field)
    false
  end
end
