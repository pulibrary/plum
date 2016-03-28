class ExhibitIdValidator < ActiveModel::Validator
  def validate(record)
    if record.exhibit_id_changed?
      exclusion_validator.validate(record)
    else
      true
    end
  end

  private

    def exclusion_validator
      ActiveModel::Validations::ExclusionValidator.new(
        attributes: :exhibit_id,
        in: existing_exhibit_ids
      )
    end

    def existing_exhibit_ids
      opts = { rows: 0, facet: true, 'facet.field': 'exhibit_id_tesim' }
      response = ActiveFedora::SolrService.get '*:*', opts
      exhibit_counts = response['facet_counts']['facet_fields']['exhibit_id_tesim']
      exhibit_counts.select.with_index { |_value, index| index.even? }
    end
end
