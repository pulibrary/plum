module CurationConcerns::DefaultFormValues
  extend ActiveSupport::Concern

  private

    def decorator
      CompositeDecorator.new(DefaultValues, super)
    end
end
