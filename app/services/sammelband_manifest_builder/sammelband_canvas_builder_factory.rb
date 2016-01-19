class SammelbandManifestBuilder
  class SammelbandCanvasBuilderFactory < ::ManifestBuilder::CanvasBuilderFactory
    def file_set_presenters
      record.file_presenters.flat_map do |presenter|
        if presenter.respond_to?(:file_presenters)
          presenter.file_presenters
        else
          presenter
        end
      end
    end
  end
end
