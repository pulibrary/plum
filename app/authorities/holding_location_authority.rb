class HoldingLocationAuthority
  include Qa::Authorities::WebServiceBase

  def all
    json(url).each { |loc| loc['id'] = loc['url'].sub(/\.json$/, '') }
  end

  def find(id)
    (all.select { |obj| obj['id'] == id } || []).first
  end

  private

    def url
      Plum.config['locations_url']
    end
end
