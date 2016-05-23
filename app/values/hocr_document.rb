class HOCRDocument
  attr_reader :document
  delegate :text, :to_s, to: :nokogiri_document
  def initialize(document)
    @document = document
  end

  def bounding_box
    BoundingBox.new(bbox_string)
  end

  def id
    nokogiri_document["id"]
  end

  def pages
    nokogiri_document.css("body > .ocr_page").map { |x| self.class.new(x) }
  end

  def areas
    nokogiri_document.css(".ocr_carea").map { |x| self.class.new(x) }
  end

  def paragraphs
    nokogiri_document.css(".ocr_par").map { |x| self.class.new(x) }
  end

  def lines
    nokogiri_document.css(".ocr_line").map { |x| self.class.new(x) }
  end

  private

    def bbox_string
      title_value.to_h['bbox']
    end

    def title_value
      @title_value ||= TitleValue.new(nokogiri_document["title"])
    end

    def nokogiri_document
      @nokogiri_document ||=
        begin
          if document.is_a?(Nokogiri::XML::Element)
            document
          else
            Nokogiri::HTML(document)
          end
        end
    end
end
