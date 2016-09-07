require 'faraday'
require 'nokogiri'
module IuMetadata
  class Client

    def self.retrieve(id, format)
      raise ArgumentError, 'Invalid id argument' unless bibdata? id
      if format == :mods
        src = retrieve_mods(id)
        data = strip_yaz(src)
        record = IuMetadata::ModsRecord.new(data)
      elsif format == :marc
        src = retrieve_marc(id)
        data = strip_yaz(src)
        record = IuMetadata::MarcRecord.new(data)
      else
        raise ArgumentError, 'Invalid format argument'
      end
      record
    end

    # Used for validating metadata identifiers in URLs
    def self.bibdata?(source_metadata_id)
      (source_metadata_id =~ /\A\w+\z/) == 0
    end

    private

    # Extracts the data payload from a YAZ Proxy response
    def self.strip_yaz(src)
      noko = Nokogiri::XML(src) do |config|
        config.strict.nonet.noblanks
      end
      data = noko.xpath('/zs:searchRetrieveResponse/zs:records/zs:record/zs:recordData/child::node()').to_s
      data
    end

    def self.retrieve_mods(id)
      conn = Faraday.new(url: 'http://dlib.indiana.edu:9000')
      response = conn.get do |req|
        req.url '/iucatextract'
        req.params['query'] = "cql.serverChoice=#{id}"
        req.params['recordSchema'] = 'mods'
        req.params['operation'] = 'searchRetrieve'
        req.params['version'] = '1.1'
        req.params['maximumRecords'] = '1'
      end
      response.body
    end

    def self.retrieve_marc(id)
      conn = Faraday.new(url: 'http://dlib.indiana.edu:9000')
      response = conn.get do |req|
        req.url '/iucatextract'
        req.params['query'] = "cql.serverChoice=#{id}"
        req.params['recordSchema'] = 'marcxml'
        req.params['operation'] = 'searchRetrieve'
        req.params['version'] = '1.1'
        req.params['maximumRecords'] = '1'
      end
      response.body
    end

  end
end
