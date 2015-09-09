module Plum
  def config
    @config ||= config_yaml.with_indifferent_access
  end

  private

    def config_yaml
      YAML.load(ERB.new(File.read("#{Rails.root}/config/config.yml")).result)[Rails.env]
    end

    module_function :config, :config_yaml
end

Hydra::Derivatives.kdu_compress_recipes = Plum.config['jp2_recipes']
