# Generated via
#  `rails generate hyrax:work EphemeraBox`
module Hyrax
  class EphemeraBoxForm < Hyrax::Forms::WorkForm
    self.model_class = ::EphemeraBox
    self.terms += [:resource_type]
  end
end
