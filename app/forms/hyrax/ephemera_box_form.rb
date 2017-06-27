# Generated via
#  `rails generate hyrax:work EphemeraBox`
module Hyrax
  class EphemeraBoxForm < ::Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::EphemeraBox
    self.terms = [:barcode, :box_number, :member_of_collection_ids, :ephemera_project_id, :shipped_date, :tracking_number]
    self.required_fields = [:barcode, :box_number, :ephemera_project_id]
    self.single_valued_fields = [:barcode, :box_number, :ephemera_project_id, :shipped_date, :tracking_number]

    def autofocus_barcode?
      true
    end

    def primary_terms
      super + [:shipped_date, :tracking_number]
    end
  end
end
