class ManifestBuilder
  class ManifestBuilderFactory
    attr_reader :record, :ssl
    def initialize(record, ssl: false)
      @record = record
      @ssl = ssl
    end

    def new
      CompositeBuilder.new(
        *manifest_presenters.map do |model|
          ChildManifestBuilder.new(model, ssl: @ssl)
        end
      )
    end

    def manifest_presenters
      record.file_presenters.select do |x|
        x.model_name.name != "FileSet"
      end
    end
  end
end
