class IIIFPath
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def to_s
    iiif_url + "/#{id}/jp2.jp2"
  end

  private

    def iiif_url
      Plum.config[:iiif_url]
    end
end
