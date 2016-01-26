module Processors
  class OCR < Hydra::Derivatives::Processors::Processor
    def process
      output_file_service.call(StringIO.new(hocr), directives)
    end

    private

      def hocr
        @hocr ||= tesseract_engine.hocr_for(source_path)
      end

      def tesseract_engine
        @tesseract_engine ||= Tesseract::Engine.new do |e|
          e.language = language
          e.page_segmentation_mode = page_segmentation_mode
        end
      end

      def language
        directives.fetch(:language, :eng)
      end

      def page_segmentation_mode
        directives.fetch(:page_segmentation_mode, :single_block)
      end
  end
end
