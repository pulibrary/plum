class RemoteEad
  delegate :title, :creator, :publisher, to: :negotiator
  
  attr_reader :identifier

  def initialize(identifier)
    @identifier = identifier
  end

  def date_created
    Array.wrap(negotiator.date)
  end

  def attributes
    {
      :title => title,
      :creator => creator,
      :publisher => publisher,
      :date_created => date_created
    }
  end

  def source
    @ead ||= begin
               response = connection.get(built_identifier)
               logger.info("Fetching #{identifier}")
               response.body
             end
  end

  private

  def connection
    Faraday.new(url: root_url)
  end


  def root_url
    'http://findingaids.princeton.edu/collections/'
  end

  def built_identifier
    identifier.tr('_', '/') + ".xml?scope=record"
  end
  
  def negotiator
    @negotiator ||= Negotiator.new(source)
  end

  def logger
    Rails.logger
  end

  class Negotiator
    include PulMetadataServices::ExternalMetadataSource
    attr_reader :ead
    def initialize(ead)
      @ead = self.class.negotiate_ead(ead)
    end
    
    def method_missing(meth_name, *args, &block)
      if self.class.respond_to?(:"#{meth_name}_from_ead")
        Array.wrap(get_property(meth_name))
      else
        super
      end
    end

    private

    def get_property(property)
      self.class.__send__(:"#{property}_from_ead", ead)
    end
  end
end
