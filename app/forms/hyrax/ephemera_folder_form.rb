# Generated via
#  `rails generate hyrax:work EphemeraFolder`
module Hyrax
  class EphemeraFolderForm < ::Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::EphemeraFolder
    self.terms = [
      :barcode,
      :folder_number,
      :title,
      :sort_title,
      :alternative_title,
      :language,
      :genre,
      :width,
      :height,
      :page_count,
      :box_id,
      :rights_statement,
      :series,
      :creator,
      :contributor,
      :publisher,
      :geographic_origin,
      :subject,
      :geo_subject,
      :description,
      :date_created,
      :related_url,
      :source,
      :member_of_collection_ids,
      :visibility
    ]
    self.required_fields = [
      :barcode,
      :box_id,
      :folder_number,
      :genre,
      :height,
      :language,
      :page_count,
      :rights_statement,
      :title,
      :width
    ]
    self.single_valued_fields = [
      :barcode,
      :creator,
      :date_created,
      :description,
      :folder_number,
      :genre,
      :geographic_origin,
      :height,
      :page_count,
      :related_url,
      :rights_statement,
      :sort_title,
      :source,
      :title,
      :width
    ]
    delegate :box_id, :project, to: :model

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

    def primary_terms
      terms - [:member_of_collection_ids, :visibility]
    end

    def secondary_terms
      []
    end
  end
end
