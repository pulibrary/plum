class CanvasBuilder
  attr_reader :record, :parent_path

  def initialize(record, parent_path)
    @record = record
    @parent_path = parent_path
    apply_record_properties
  end

  def canvas
    @canvas ||= Canvas.new
  end

  def path
    CanvasID.new(record.id, parent_path.to_s).to_s
  end

  def apply(sequence)
    sequence.canvases += [canvas]
  end

  class Canvas < IIIF::Presentation::Canvas
    def legal_viewing_hint_values
      super + ['facing-pages']
    end
  end

  private

    def apply_record_properties
      canvas['@id'] = path
      canvas.label = record.to_s
      canvas.viewing_hint = record.viewing_hint if record.viewing_hint
      attach_image
      attach_other_content
    end

    def attach_image
      iiif_path = IIIFPath.new(record.id)
      image = IIIF::Presentation::ImageResource.create_image_api_image_resource(
        service_id: iiif_path.to_s,
        resource_id: "#{iiif_path}/full/!600,600/0/default.jpg",
        format: 'image/jpeg',
        profile: 'http://iiif.io/api/image/2/level2.json',
        width: record.width,
        height: record.height
      )
      annotation = IIIF::Presentation::Annotation.new
      annotation.resource = image
      annotation["on"] = path
      annotation["@id"] = parent_path.to_s + "/annotation/#{record.id}-image"
      canvas.images << annotation
      canvas.width = image.width
      canvas.height = image.height
    end

    def attach_other_content
      id = parent_path.send(:helper).text_curation_concerns_member_file_set_url(parent_path.record, record)
      resource = {
        "@id" => id,
        "@type" => "sc:AnnotationList",
        "label" => "Text of this Page"
      }
      canvas["otherContent"] = [resource]
    end
end
