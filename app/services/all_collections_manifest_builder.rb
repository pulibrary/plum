class AllCollectionsManifestBuilder < ManifestBuilder
  def initialize(record = nil, ssl: false)
    super
  end

  private

    def root_path
      "#{helper.root_url(protocol: protocol)}collections/manifest"
    end

    def protocol
      if @ssl
        :https
      else
        :http
      end
    end

    def helper
      @helper ||= ManifestBuilder::ManifestHelper.new
    end

    def record
      @record ||= AllCollectionsPresenter.new
    end
end
