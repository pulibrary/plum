module EphemeraFieldsHelper
  def controllable_fields
    controllable_concerns.map {|t| t.controlled_fields.map {|field| "#{t}.#{field}" } }.flatten
  end

  private

    def controllable_concerns
      Hyrax.config.curation_concerns.select {|t| t.respond_to?(:controlled_fields) }
    end
end
