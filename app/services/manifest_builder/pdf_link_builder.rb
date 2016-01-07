class ManifestBuilder
  class PDFLinkBuilder
    attr_reader :record, :ssl
    def initialize(record, ssl: false)
      @record = record
      @ssl = ssl
    end

    def apply(manifest)
      return if record.file_presenters.length == 0
      return if manifest['sequences'].blank?
      manifest['sequences'].first['rendering'] = {
        '@id' => path,
        'label' => label,
        'format' => format
      }
    end

    private

      def path
        helper.polymorphic_url([:pdf, record], protocol: protocol)
      end

      def helper
        @helper ||= ManifestPath::RouteHelper.new
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
