# Generated via
#  `rails generate hyrax:work EphemeraBox`
module Hyrax
  class EphemeraBoxForm < ::Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::EphemeraBox
    self.terms = [:barcode, :box_number, :member_of_collection_ids]
    self.required_fields = [:barcode, :box_number]
    self.single_valued_fields = [:barcode, :box_number]

    def autofocus_barcode?
      true
    end
  end
end
