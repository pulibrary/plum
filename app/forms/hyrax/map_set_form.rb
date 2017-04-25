module Hyrax
  class MapSetForm < ::Hyrax::GeoWorkForm
    self.model_class = ::MapSet

    self.terms += [:resource_type, :viewing_direction, :viewing_hint, :alternative, :edition, :cartographic_scale]
    self.required_fields = [:title, :source_metadata_identifier, :rights_statement, :coverage]

    def primary_terms
      super + [:portion_note, :nav_date]
    end

    def secondary_terms
      super + [:cartographic_scale, :alternative, :edition]
    end
  end
end
