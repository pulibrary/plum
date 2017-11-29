# frozen_string_literal: true
module Extractors
  class FgdcMetadataExtractor < GeoWorks::Extractors::FgdcMetadataExtractor
    # Override keywords method to exlcude non-ISO topic categories
    def keywords
      keywords = extract_multivalued('//idinfo/keywords/theme/themekey')
      keywords.select! { |k| TOPIC_CATEGORIES[k.to_sym].present? }
      keywords.map! { |k| TOPIC_CATEGORIES[k.to_sym] }
      keywords.uniq!
      keywords.present? ? keywords : nil
    end
  end
end
