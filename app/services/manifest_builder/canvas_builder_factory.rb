class ManifestBuilder
  class CanvasBuilderFactory
    attr_reader :record
    def initialize(record)
      @record = record
    end

    def new(root_path)
      CompositeBuilder.new(
        *file_set_presenters.map do |generic_file|
          CanvasBuilder.new(generic_file, root_path)
        end
      )
    end

    private

      def file_set_presenters
        record.file_presenters.select do |x|
          x.model_name.name == "FileSet"
        end
      end
  end
end
