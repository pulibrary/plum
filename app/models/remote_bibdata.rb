class RemoteBibdata
  delegate :title, :creator, :publisher, to: :negotiator

  attr_reader :identifier

  def initialize(identifier)
    @identifier = identifier
  end

  def date_created
    negotiator.date
  end

  def attributes
    {
      title: title,
      creator: creator,
      date_created: date_created,
      publisher: publisher
    }
  end

  def source
    @marc_record ||= begin
                       response = connection.get(identifier)
                       logger.info("Fetching #{identifier}")
                       response.body
                     end
  end

  private

    def connection
      Faraday.new(url: root_url)
    end

    def root_url
      'http://bibdata.princeton.edu/bibliographic/'
    end

    def negotiator
      @negotiator ||= Negotiator.new(source)
    end

    def logger
      Rails.logger
    end

    class Negotiator
      include PulMetadataServices::ExternalMetadataSource
      attr_reader :marc_record
      def initialize(marc_record)
        @marc_record = self.class.negotiate_record(marc_record)
      end

      def method_missing(meth_name, *args, &block)
        if self.class.respond_to?(:"#{meth_name}_from_marc")
          Array.wrap(get_property(meth_name))
        else
          super
        end
      end

      private

        def get_property(property)
          self.class.__send__(:"#{property}_from_marc", marc_record)
        end
    end
end
