class SammelbandManifestBuilder
  class SammelbandCanvasBuilderFactory < ::ManifestBuilder::CanvasBuilderFactory
    def file_set_presenters
      record.member_presenters.flat_map do |presenter|
        if presenter.respond_to?(:member_presenters)
          presenter.member_presenters
        else
          presenter
        end
      end
    end
  end
end
