# Generated via
#  `rails generate hyrax:work EphemeraBox`
module Hyrax
  class EphemeraBoxForm < SingleValuedForm
    self.model_class = ::EphemeraBox
    self.terms = [:box_number, :barcode, :member_of_collection_ids]
    self.required_fields = [:box_number, :barcode]
    self.single_valued_fields = [:barcode, :box_number]
  end
end
