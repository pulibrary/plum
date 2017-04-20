# Uses hOCR to create a JSON word boundaries file.
class WordBoundariesRunner

  def initialize(id)
    @id = id
    @file_set = FileSet.find(id)
  end

  def create
    doc = File.open(hocr_filepath()) { |f| Nokogiri::HTML(f) }
    json = {}
    doc.css('span.ocrx_word').each do |span|
      text = span.text
      next if text.length < 3
      # Filter out non-word characters
      word_match = text.match /\w+/
      next if word_match.nil?

      title = span['title']
      info = parse_hocr_title(title)

      text.split(/\W/).each do |word_part|
        json[word_part] ||= []
        json[word_part] << info
      end
    end
    File.open(json_filepath(), 'w') do |fh|
      fh.puts json.to_json
    end

    if hocr_exists?
      file_set = FileSet.find(@id)
      #file_set.json = DateTime.now
      file_set.save
    end
  end

  def hocr_filepath
    # Path to hocr derivative
    path = PairtreeDerivativePath.derivative_path_for_reference(@file_set, "ocr")
  end

  def json_filepath
    # Path to json derivative
    path = PairtreeDerivativePath.derivative_path_for_reference(@file_set, "json")
  end

  def hocr_exists?
    # Check if hocr already created
    File.exist?(hocr_filepath)
  end

  def json_exists?
    # Check if Word Boundaries file already created.
    File.exist?(json_filepath)
  end

  private

  def parse_hocr_title(title)
    parts = title.split(';').map(&:strip)
    info = {}
    parts.each do |part|
      sections = part.split(' ')
      sections.shift
      if /^bbox/.match(part)
        x0, y0, x1, y1 = sections
        info['x0'], info['y0'], info['x1'], info['y1'] = [x0.to_i, y0.to_i, x1.to_i, y1.to_i]
      elsif /^x_wconf/.match(part)
        c = sections.first
        info['c'] = c.to_i
      end
    end
    info
  end

end
