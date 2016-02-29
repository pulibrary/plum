class ScannedResourcePDF
  class CoverPageGenerator
    attr_reader :scanned_resource_pdf
    delegate :scanned_resource, to: :scanned_resource_pdf
    delegate :solr_document, to: :scanned_resource
    def initialize(scanned_resource_pdf)
      @scanned_resource_pdf = scanned_resource_pdf
    end

    def header(prawn_document, header, size: 24)
      prawn_document.text header, size: size, styles: [:bold]
      prawn_document.stroke do
        prawn_document.horizontal_rule
      end
      prawn_document.move_down 20
    end

    def apply(prawn_document)
      prawn_document.bounding_box([15, Canvas::LETTER_HEIGHT - 15], width: Canvas::LETTER_WIDTH - 30, height: Canvas::LETTER_HEIGHT - 30) do
        prawn_document.image Rails.root.join("app/assets/images/pul_logo_long.png").to_s, position: :center, width: Canvas::LETTER_WIDTH - 30
        prawn_document.stroke_color "000000"
        prawn_document.move_down(20)
        header(prawn_document, scanned_resource.to_s, size: 30)
        solr_document.rights_statement.each do |statement|
          prawn_document.text RightsStatementService.definition(statement), align: :justify
        end
        prawn_document.move_down 20

        header(prawn_document, "Princeton University Library Disclaimer")
        prawn_document.text I18n.t('rights.pdf_boilerplate'), inline_format: true
        prawn_document.move_down 20

        header(prawn_document, "Citation Information")

        header(prawn_document, "Contact Information")
        text = HoldingLocationRenderer.new(solr_document.holding_location).value_html.gsub("<a", "<u><a").gsub("</a>", "</a></u>")
        prawn_document.text text, inline_format: true
        prawn_document.move_down 20

        header(prawn_document, "Download Information")
        prawn_document.text "Date Rendered: #{Time.current.strftime('%Y-%m-%d %I:%M:%S %p %Z')}"
        prawn_document.text "Available Online at: <u><a href='#{helper.polymorphic_url(scanned_resource)}'>#{helper.polymorphic_url(scanned_resource)}</a></u>", inline_format: true
      end
    end

    private

      def helper
        @helper ||= ManifestBuilder::ManifestHelper.new
      end
  end
end
