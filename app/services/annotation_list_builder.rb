class AnnotationListBuilder
  attr_reader :file_set, :parent_path, :canvas_id
  delegate :to_json, to: :annotation_list
  def initialize(file_set, parent_path, canvas_id)
    @file_set = file_set
    @parent_path = parent_path
    @canvas_id = canvas_id
    apply_record_properties
  end

  def as_json
    JSON.parse(annotation_list.to_json)
  end

  private

    def apply_record_properties
      annotation_list["@id"] = parent_path
      resource_builders.apply(annotation_list)
    end

    def annotation_list
      @annotation_list ||= IIIF::Presentation::AnnotationList.new
    end

    def resource_builders
      ManifestBuilder::CompositeBuilder.new(
        *(file_set.ocr_document.try(:lines) || []).map do |line|
          ResourceBuilder.new(line, canvas_id, parent_path)
        end
      )
    end

    class ResourceBuilder
      attr_reader :ocr_node, :canvas_id, :parent_path
      def initialize(ocr_node, canvas_id, parent_path)
        @ocr_node = ocr_node
        @canvas_id = canvas_id
        @parent_path = parent_path
      end

      def apply(annotation_list)
        annotation_list.resources << annotation
        annotation_list
      end

      private

        def annotation
          @annotation ||=
            begin
              annotation = IIIF::Presentation::Annotation.new
              annotation['@id'] = "#{parent_path}/#{ocr_node.id}"
              annotation['on'] = "#{canvas_id}#xywh=#{bounding_box}"
              annotation.resource = annotation_resource
              annotation
            end
        end

        def bounding_box
          b = ocr_node.bounding_box
          "#{b.top_left.x},#{b.top_left.y},#{b.width},#{b.height}"
        end

        def annotation_resource
          @annotation_resource ||=
            begin
              resource = IIIF::Presentation::Resource.new
              resource.format = "text/plain"
              resource['@id'] = "#{parent_path}/#{ocr_node.id}/1"
              resource['@type'] = "cnt:ContentAsText"
              resource['chars'] = ocr_node.text
              resource
            end
        end
    end
end
