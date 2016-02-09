class ScannedResourcePDF
  class CoverPageGenerator
    attr_reader :scanned_resource_pdf
    delegate :scanned_resource, to: :scanned_resource_pdf
    delegate :solr_document, to: :scanned_resource
    def initialize(scanned_resource_pdf)
      @scanned_resource_pdf = scanned_resource_pdf
    end

    def apply(prawn_document)
      prawn_document.bounding_box([15, Canvas::LETTER_HEIGHT - 15], width: Canvas::LETTER_WIDTH - 30, height: Canvas::LETTER_HEIGHT - 30) do
        prawn_document.text scanned_resource.to_s, size: 24, align: :center
        prawn_document.move_down 5
        prawn_document.text "(<a href='#{helper.polymorphic_url(scanned_resource)}'>#{helper.polymorphic_url(scanned_resource)}</a>)", align: :center, inline_format: true, size: 10
        prawn_document.move_down 16
        prawn_document.text "Rights", size: 16, align: :center
        prawn_document.move_down 16
        solr_document.rights_statement.each do |statement|
          prawn_document.text RightsService.label(statement), size: 16, align: :center
          prawn_document.move_down 16
          prawn_document.text RightsStatementService.definition(statement), align: :justify
        end
        prawn_document.move_down 16
        prawn_document.text I18n.t('rights.boilerplate'), inline_format: true
        prawn_document.move_down 16
        prawn_document.text "Holding Location", size: 16, align: :center
        prawn_document.move_down 16
        prawn_document.text HoldingLocationRenderer.new(solr_document.holding_location).value_html, inline_format: true, align: :justify
      end
    end

    private

      def helper
        @helper ||= ManifestBuilder::ManifestHelper.new
      end
  end
end
