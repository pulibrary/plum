class ManifestBuilder
  class ManifestBuilderFactory
    attr_reader :record, :ssl, :child_factory
    def initialize(record, child_factory: ChildManifestBuilder, ssl: false)
      @record = record
      @ssl = ssl
      @child_factory = child_factory
    end

    def new
      CompositeBuilder.new(
        *manifest_presenters.map do |model|
          child_factory.new(model, ssl: @ssl)
        end
      )
    end

    def manifest_presenters
      record.member_presenters.select do |x|
        x.model_name.name != "FileSet" && (!x.current_ability || x.current_ability.can?(:read, x.solr_document))
      end
    end
  end
end
