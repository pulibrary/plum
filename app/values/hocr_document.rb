class HOCRDocument
  attr_reader :document
  delegate :text, to: :nokogiri_document
  def initialize(document)
    @document = document
  end

  def bounding_box
    BoundingBox.new(bbox_string)
  end

  private

    def bbox_string
      title_value.to_h['bbox']
    end

    def title_value
      @title_value ||= TitleValue.new(nokogiri_document.css(".ocr_page")[0]['title'])
    end

    def nokogiri_document
      @nokogiri_document ||= Nokogiri::HTML(document)
    end
end
