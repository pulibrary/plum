# rubocop:disable Metrics/ClassLength
module IuMetadata
  class MarcRecord
    def initialize(id, source)
      @id = id
      @source = source
    end

    attr_reader :id, :source

    ATTRIBUTES = [:identifier, :title, :sort_title, :responsibility_note, :series, :creator, :subject, :publisher, :publication_place, :date_published, :published, :lccn_call_number, :local_call_number]

    def attributes
      ATTRIBUTES.map { |att| [att, send(att)] }.to_h.compact
    end

    # used attributes

    def abstract
      formatted_fields_as_array('520')
    end

    def alternative_titles
      alt_titles = []
      alt_title_field_tags.each do |tag|
        data.fields(tag).each do |field| # some of these tags are repeatable
          exclude_subfields = tag == '246' ? ['i'] : []
          alt_titles << format_datafield(field, exclude_alpha: exclude_subfields)
          if linked_field?(field)
            field = get_linked_field(field)
            alt_titles << format_datafield(field, exclude_alpha: exclude_subfields)
          end
        end
      end
      alt_titles
    end

    def audience
      formatted_fields_as_array('521')
    end

    def citation
      formatted_fields_as_array('524')
    end

    def contributors
      fields = []
      contributors = []
      if creator.empty? && record.any_7xx_without_t?
        fields.push(*record.fields(['100', '110', '111']))
        fields.push(*record.fields(['700', '710', '711']).select { |df| !df['t'] })
        # By getting all of the fields first and then formatting them we keep
        # the linked field values adjacent to the romanized values. It's a small
        # thing, but may be useful.
        fields.each do |field|
          contributors << format_datafield(field)
          if linked_field?(field)
            contributors << format_datafield(get_linked_field(field))
          end
        end
      end
      contributors
    end

    def creator
      creator = []
      if any_1xx?
        field = data.fields(['100', '110', '111'])[0]
        creator << format_datafield(field)
        if linked_field?(field)
          creator << format_datafield(get_linked_field(field))
        end
      end
      trim_punctuation creator
    end

    # no longer used
    def date_created
      Array.wrap(date)
    end

    def date
      date_from_008
    end

    def description
      formatted_fields_as_array([
        '500', '501', '502', '504', '507', '508', '511', '510', '513', '514',
        '515', '516', '518', '522', '525', '526', '530', '533', '534', '535',
        '536', '538', '542', '544', '545', '546', '547', '550', '552', '555',
        '556', '562', '563', '565', '567', '580', '581', '583', '584', '585',
        '586', '588', '590'
      ])
    end

    def extent
      formatted_fields_as_array('300')
    end

    def parts
      parts = []
      parts_fields.each do |f|
        parts << format_datafield(f)
        parts << format_datafield(get_linked_field(f)) if linked_field?(f)
      end
      parts
    end

    def identifier
      formatted_subfields_as_array(['856'], codes: ['u']).first
    end

    def date_published
      formatted_subfields_as_array(['260'], codes: ['c'])
    end

    def language_codes
      codes = []
      from_fixed = data['008'].value[35, 3]
      codes << from_fixed unless ['   ', 'mul'].include? from_fixed

      data.fields('041').each do |df|
        df = df.select { |sf| ['a', 'd', 'e', 'g'].include? sf.code }
        df.map(&:value).each do |c|
          if c.length == 3
            codes << c
          elsif c.length % 3 == 0
            codes.push(*c.scan(/.{3}/))
          end
        end
      end
      codes.uniq
    end

    def lccn_call_number
      formatted_fields_as_array(['090'], exclude_alpha: ['m'])
    end

    def local_call_number
      formatted_fields_as_array(['099'])
    end

    def provenance
      formatted_fields_as_array(['541', '561'])
    end

    def publication_place
      formatted_subfields_as_array(['260', '264'], codes: ['a'])
    end

    def published
      formatted_fields_as_array(['260', '264']).first
    end

    def publisher
      formatted_subfields_as_array(['260', '264'], codes: ['b'])
    end

    def responsibility_note
      formatted_fields_as_array(['245'], codes: ['c'])
    end

    def rights
      formatted_fields_as_array(['506', '540'])
    end

    def sort_title
      title(false)[0]
    end

    def series
      formatted_fields_as_array(['440', '490', '800', '810', '811', '830'])
    end

    def title(include_initial_article = true)
      title_tag = determine_primary_title_field
      ti_field = data.fields(title_tag)[0]

      titles = []

      if title_tag == '245'
        ti = format_datafield(ti_field).split(' / ')[0]
        unless include_initial_article
          to_chop = data['245'].indicator2.to_i
          ti = ti[to_chop, ti.length - to_chop]
        end

        titles << ti

        if linked_field?(ti_field)
          linked_field = get_linked_field(ti_field)
          vern_ti = format_datafield(linked_field).split(' / ')[0]
          unless include_initial_article
            to_chop = linked_field.indicator2.to_i
            vern_ti = vern_ti[to_chop, ti.length - to_chop]
          end
          titles << vern_ti
        end

      else
        # TODO: exclude 'i' when 246
        titles << format_datafield(ti_field)
        if linked_field?(ti_field)
          titles << format_datafield(get_linked_field(ti_field))
        end
      end
      titles
    end

    def subject
      # Broken: name puctuation won't come out correctly
      formatted_fields_as_array([
        '600', '610', '611', '630', '648', '650', '651', '653', '654', '655',
        '656', '657', '658', '662', '690'
      ], codes: ['a'])
    end

    # We squash together 505s with ' ; '
    def contents
      entry_sep = ' ; '
      contents = []
      data.fields('505').each do |f|
        entry = format_datafield(f)
        if linked_field?(f)
          entry += " = "
          entry += format_datafield(get_linked_field(f))
        end
        contents << entry
      end
      contents.join entry_sep
    end

    def formatted_fields_as_array(fields, opts = {})
      vals = []
      data.fields(fields).each do |field|
        val = format_datafield(field, opts)
        vals << val if val != ""
        next unless linked_field?(field)
        linked_field = get_linked_field(field)
        val = format_datafield(linked_field, opts)
        vals << val if val != ""
      end
      trim_punctuation(vals)
    end

    def formatted_subfields_as_array(fields, opts = {})
      vals = []
      data.fields(fields).each do |field|
        val = format_subfields(field, opts)
        vals += val if val.present?
        next unless linked_field?(field)
        linked_field = get_linked_field(field)
        val = format_subfields(linked_field, opts)
        vals += val if val.present?
      end
      trim_punctuation(vals)
    end

    def format_datafield(datafield, hsh = {})
      separator = hsh.fetch(:separator, ' ')
      format_subfields(datafield, hsh).join(separator)
    end

    def format_subfields(datafield, hsh = {})
      codes = hsh.fetch(:codes, ALPHA).dup
      exclude_alpha = hsh.fetch(:exclude_alpha, [])
      exclude_alpha.each { |ex| codes.delete ex }
      subfield_values = []
      datafield.select { |sf| codes.include? sf.code }.each do |sf|
        subfield_values << sf.value
      end
      subfield_values
    end

    private

      BIB_LEADER06_TYPES = %w(a c d e f g i j k m o p r t)
      TITLE_FIELDS_BY_PREF = %w(245 240 130 246 222 210 242 243 247)
      ALPHA = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)

      def data
        @data ||= reader.select { |r| BIB_LEADER06_TYPES.include?(r.leader[6]) }[0]
      end

      def reader
        @reader ||= MARC::XMLReader.new(StringIO.new(source))
      end

      def any_1xx?
        data.tags.any? { |t| ['100', '110', '111'].include? t }
      end

      def any_7xx_without_t?
        data.fields(['700', '710', '711']).select { |df| !df['t'] } != []
      end

      def get_linked_field(src_field)
        return unless src_field['6']
        idx = src_field['6'].split('-')[1].split('/')[0].to_i - 1
        data.select { |df| df.tag == '880' }[idx]
      end

      def date_from_008
        return unless data['008']
        d = data['008'].value[7, 4]
        d = d.tr 'u', '0' unless d == 'uuuu'
        d = d.tr ' ', '0' unless d == '    '
        d if d =~ /^[0-9]{4}$/
      end

      def determine_primary_title_field
        (TITLE_FIELDS_BY_PREF & data.tags)[0]
      end

      def alt_title_field_tags
        other_title_fields = *TITLE_FIELDS_BY_PREF
        while !other_title_fields.empty? && !found_title_tag ||= false
          # the first one we find will be the title, the rest we want
          found_title_tag = data.tags.include? other_title_fields.shift
        end
        other_title_fields
      end

      def linked_field?(datafield)
        !datafield['6'].nil?
      end

      def parts_fields
        fields = []
        data.fields(['700', '710', '711', '730', '740']).each do |field|
          if ['700', '710', '711'].include?(field.tag) && field['t']
            fields << field
          elsif field.tag == '740' && field.indicator1 == '2'
            fields << field
          elsif field.tag == '730'
            fields << field
          end
        end
        fields
      end

      def trim_punctuation(ary)
        ary.map { |s| s.sub(/\s*[:;,.]\s*$/, '') }
      end
  end
end
# rubocop:enable Metrics/ClassLength
