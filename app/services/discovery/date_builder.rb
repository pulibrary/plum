# frozen_string_literal: true
module Discovery
  class DateBuilder < GeoWorks::Discovery::DocumentBuilder::DateBuilder
    private

      # Overrides the date field parsing from GeoWorks
      # Builds date fields such as layer year and modified date.
      # Prefers the field parsed by GeoWorks, but defaults to <dc:date>
      # @return [Integer] year
      def layer_year
        year = super
        if year.blank?
          date = geo_concern.date.first
          year_m = date.match(/(?<=\D|^)(\d{4})(?=\D|$)/)
          year = year_m ? year_m[0].to_i : nil
        end
        year
      rescue
        ''
      end
  end
end
