class ManifestBuilder
  class PDFLinkBuilder
    attr_reader :record, :ssl
    def initialize(record, ssl: false)
      @record = record
      @ssl = ssl
    end

    def apply(manifest)
      return if record.member_presenters.length == 0
      return if manifest['sequences'].blank?
      return unless path
      manifest['sequences'].first['rendering'] = {
        '@id' => path,
        'label' => label,
        'format' => format
      }
    end

    private

      def path
        if record.pdf_type.empty?
          helper.polymorphic_url([:pdf, record], pdf_quality: "gray", protocol: protocol)
        else
          helper.polymorphic_url([:pdf, record], pdf_quality: record.pdf_type.first, protocol: protocol)
        end
      rescue
        nil
      end

      def helper
        @helper ||= ManifestHelper.new
      end

      def label
        'Download as PDF'
      end

      def format
        'application/pdf'
      end

      def protocol
        if ssl
          :https
        else
          :http
        end
      end
  end
end
