module SolrDates
  extend ActiveSupport::Concern
  included do
    def date_modified
      formatted_date('date_modified')
    end

    def date_uploaded
      formatted_date('date_uploaded')
    end
  end

  def date_created
    self[Solrizer.solr_name('date_created')]
  end

  def date_created_display
    DateValue.new(date_created).to_a
  end

  private

    def formatted_date(field_name)
      value = first(Solrizer.solr_name(field_name, :stored_sortable, type: :date))
      begin
        DateTime.parse(value).in_time_zone(Time.now.zone).strftime("%D %r %Z")
      rescue
        Rails.logger.info "Unable to parse date: #{value.inspect} for #{self['id']}"
      end
    end
end
