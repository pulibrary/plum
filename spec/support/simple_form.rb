module SimpleFormHelper
  extend ActiveSupport::Concern
  def simple_form_for(*args)
    form = nil
    view.simple_form_for(*args) do |f|
      form = f
    end
    form
  end
end

RSpec.configure do |config|
  config.include SimpleFormHelper, type: :view
end
