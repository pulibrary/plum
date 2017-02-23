module SolrDates
  extend ActiveSupport::Concern
  included do
    def date_modified
      formatted_date('date_modified')
    end

    def date_uploaded
      formatted_date('date_uploaded')
    end

    def system_modified
      formatted_date('system_modified')
    end

    def create_date
      formatted_date('system_create')
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
        DateTime.parse(value).in_time_zone(Time.zone).strftime("%D %r %Z")
      rescue
        Rails.logger.info "Unable to parse date: #{value.inspect} for #{self['id']}"
        nil
      end
    end
end
