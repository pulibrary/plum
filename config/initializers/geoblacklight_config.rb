module Geoblacklight
  def config
    @config ||= config_yaml.with_indifferent_access
  end

  private

    def config_yaml
      YAML.load(ERB.new(File.read("#{Rails.root}/config/geoblacklight.yml")).result)[Rails.env]
    end

    module_function :config, :config_yaml
end
