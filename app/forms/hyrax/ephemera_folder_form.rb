# Generated via
#  `rails generate hyrax:work EphemeraFolder`
module Hyrax
  class EphemeraFolderForm < ::Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::EphemeraFolder
    self.terms = [:language, :title, :sort_title, :alternative_title, :series, :creator, :contributor, :publisher, :geographic_origin, :genre, :subject, :geo_subject, :description, :date_created, :identifier, :folder_number, :genre, :width, :height, :page_count, :box_id, :member_of_collection_ids, :rights_statement]
    self.required_fields = [:title, :identifier, :folder_number, :width, :height, :page_count, :box_id, :language, :genre, :rights_statement]
    self.single_valued_fields = [:title, :sort_title, :creator, :geographic_origin, :date_created, :genre, :description, :identifier, :folder_number, :genre, :width, :height, :page_count, :rights_statement]
    delegate :box_id, to: :model

    def rights_statement
      if self[:rights_statement].present?
        self[:rights_statement]
      else
        "http://rightsstatements.org/vocab/NKC/1.0/"
      end
    end

    def autofocus_barcode?
      true
    end
  end
end
