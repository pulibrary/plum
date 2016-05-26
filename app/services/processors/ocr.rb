module Processors
  class OCR < Hydra::Derivatives::Processors::Processor
    include Hydra::Derivatives::Processors::ShellBasedProcessor
    class << self
      def encode(path, options, output_file)
        execute "tesseract #{path} #{output_file.gsub('.hocr', '')} #{options[:options]} hocr"
      end
    end

    def options_for(_format)
      {
        options: string_options
      }
    end

    private

      def string_options
        "-l #{language}"
      end

      def language
        directives.fetch(:language, :eng)
      end
  end
end
