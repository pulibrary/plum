class HoldingLocationAuthority

  def all
    digital_locations
  end

  def find(id)
    (all.select { |obj| obj['id'] == id } || []).first
  end

  private

    def digital_locations
      @digital_locations ||= YAML.load(File.read('config/digital_locations.yml'))
    end
end
