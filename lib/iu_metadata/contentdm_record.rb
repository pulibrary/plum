# rubocop:disable Metrics/ClassLength
module IuMetadata
  class ContentdmRecord
    def initialize(id, source)
      @id = id
      @source = source
      @cdm = Nokogiri::XML(source)
      parse
    end
    attr_reader :id, :source

    # standard metadata
    ATTRIBUTES = [:source_metadata_identifier, :viewing_direction]

    def attributes
      ATTRIBUTES.map { |att| [att, send(att)] }.to_h.compact
    end

    def source_metadata_identifier
      @cdm.xpath('/metadata/record/isPartOf').first.content.to_s
    end

    def viewing_direction
      'left-to-right'
    end

    # no custom default metadadata

    # ingest metadata
    attr_reader :files, :structure, :volumes, :thumbnail_path

    def multi_volume?
      items.size > 1
    end

    def collections
      []
    end

    private

      def items
        @items ||= @cdm.xpath('/metadata/record')
      end

      def parse
        @files = []
        @cdm.xpath('//record').each do |record|
          title = record.xpath('title').first&.content.to_s
          record.xpath('structure/page').each do |file|
            file_hash = {}
            tid = file.xpath('pagetitle').first&.content.to_s
            file_hash[:id] = tid
            file_hash[:mime_type] = 'image/jp2'
            file_hash[:attributes] = {}
            file_hash[:attributes][:title] = [tid.to_s]
            file.xpath('pagefile').each do |pagefile_xml|
              pagefile_type = pagefile_xml.xpath('pagefiletype').map(&:content).first.to_s
              # File type should be one of: original, thumbnail, extracted
              case pagefile_type
              when 'access'
                path = pagefile_xml.xpath('pagefilelocation').map(&:content).first.to_s
                fp = fix_path_iupui(path)
                file_hash[:path] = fp
              when 'thumbnail'
                path = pagefile_xml.xpath('pagefilelocation').map(&:content).first.to_s
                fp = fix_path_iupui(path)
                file_hash[:thumbnail] = fp
              else
                next
              end
            end
            full_text = content_fulltext(file, title, tid)
            file_hash[:ocr_path] = full_text
            file_hash[:file_opts] = {}
            @files << file_hash
          end
        end

        # assign structure hash and update files array with titles
        @file_index = 0
        if multi_volume?
          @volumes = []
          @file_start = 0
          items.each do |item|
            volume = {}
            volume[:title] = [item['title']]
            volume[:title] = [item.xpath('title').map(&:content).first.to_s]
            volume[:structure] = { nodes: record_to_structure_array(item) }
            volume[:files] = @files[@file_start, @file_index - @file_start]
            @file_start = @file_index
            @volumes << volume
          end
        else
          @structure = { nodes: record_to_structure(items.first) }
        end
      end

      def record_to_structure_array(record)
        array = []
        record.xpath('structure/page').each do |page|
          c = {}
          c[:label] = page.xpath('pagetitle').map(&:content).first.to_s
          c[:proxy] = page.xpath('pagetitle').map(&:content).first.to_s
          @file_index += 1
          array << c
        end
        array
      end

      # Pull out fulltext from export file
      #
      # @param [XML_Object]  page_xml
      # @param [String] content_dir directory for full text
      # @return [String] path to ocr text
      def content_fulltext(page_xml, paper_title, page_title)
        page_path = Pathname.new(@source)
        basename = page_path.basename.to_s.gsub('.xml', '')
        full_text_path = File.join(page_path.parent, basename, paper_title, page_title)
        full_text_file = "#{full_text_path}/fulltext.txt"
        FileUtils.mkdir_p full_text_path
        page_text = page_xml.xpath('pagetext').map(&:content).first.to_s
        File.open(full_text_file, "w") { |f| f.write(page_text) }
        full_text_file.gsub Pathname.pwd.to_s + "/", ""
      end

      # Fix file paths for IUPUI exports
      #
      # @param [String] path given from IUPUI contentDM export
      # @return [String] corrected path using new API port for IUPUI contentDM
      def fix_path_iupui(path)
        # IUPUI CDM no longer provides API on port 445
        # The API is now available on port 2012
        # Also needs to replace &amp; with just &
        CGI.unescapeHTML(path.sub(/445\/cgi-bin/, '2012/cgi-bin'))
      end
  end
end
# rubocop:enable Metrics/ClassLength
