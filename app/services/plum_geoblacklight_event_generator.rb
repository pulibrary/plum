class PlumGeoblacklightEventGenerator
  def record_created
    publish_message(
      message("CREATED", record)
    )
  end

  def record_deleted(record)
    publish_message(
      delete_message("DELETED", record)
    )
  end

  def record_updated(record)
    publish_message(
      message("UPDATED", record)
    )
  end

  private

    def publish_message(message)
      messaging_client.publish(message.to_json)
    end

    def messaging_client
      Plum.geoblacklight_messaging_client
    end

    def message(type, record)
      base_message(type, record).merge("exchange" => :geoblacklight,
                                       "doc" => generate_document(record))
    end

    def delete_message(type, record)
      base_message(type, record).merge("exchange" => :geoblacklight,
                                       "id" => slug(record))
    end

    def base_message(type, record)
      {
        "id" => record.id,
        "event" => type
      }
    end

    def generate_document(record)
      GeoWorks::Discovery::DocumentBuilder.new(record, GeoWorks::Discovery::GeoblacklightDocument.new)
    end

    def slug(record)
      Discovery::SlugBuilder.new(record).slug
    end
end
