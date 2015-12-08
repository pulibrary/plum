class ExhibitIdValidator < ActiveModel::Validator
  delegate :validate, to: :exclusion_validator

  private

    def exclusion_validator
      ActiveModel::Validations::ExclusionValidator.new(
        attributes: :exhibit_id,
        in: existing_exhibit_ids
      )
    end

    def existing_exhibit_ids
      opts = { raw: true, rows: 0, facet: true, 'facet.field': 'exhibit_id_tesim' }
      response = ActiveFedora::SolrService.query '*:*', opts
      exhibit_counts = response['facet_counts']['facet_fields']['exhibit_id_tesim']
      exhibit_counts.select.with_index { |_value, index| index.even? }
    end
end
