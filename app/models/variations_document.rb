# rubocop:disable Metrics/ClassLength
class VariationsDocument
  include PreingestableDocument
  FILE_PATTERN = '*.xml'

  def initialize(source_file)
    @source_file = source_file
    @variations = File.open(@source_file) { |f| Nokogiri::XML(f) }
    @source_title = ['Variations XML']
    parse
  end

  attr_reader :source_file, :source_title
  attr_reader :files, :structure, :volumes, :thumbnail_path

  def yaml_file
    source_file.sub(/\.xml$/, '.yml')
  end

  def source_metadata_identifier
    @variations.xpath('//MediaObject/Label').first.content.to_s
  end

  def viewing_direction
    'left-to-right'
  end

  def viewing_hint
    'paged'
  end

  def location
    @variations.xpath('//Container/PhysicalID/Location').first&.content.to_s
  end

  def holding_location
    case location
    when 'IU Music Library'
      'https://libraries.indiana.edu/music'
    when 'Personal Collection'
      ''
    else
      ''
    end
  end

  def default_attributes
    super.merge(visibility: visibility, rights_statement: rights_statement, viewing_hint: viewing_hint)
  end

  def local_attributes
    { source_metadata_identifier: source_metadata_identifier,
      identifier: identifier,
      holding_location: holding_location,
      physical_description: physical_description,
      copyright_holder: copyright_holder
    }
  end

  def identifier
    'http://purl.dlib.indiana.edu/iudl/variations/score/' + source_metadata_identifier
  end

  def physical_description
    @variations.xpath("//Container/DocumentInfos/DocumentInfo[Type='Score']/Description").first&.content.to_s
  end

  def copyright_holder
    @variations.xpath("//Container/CopyrightDecls/CopyrightDecl/Owner").map(&:content)
  end

  def holding_status
    @variations.xpath('//Container/HoldingStatus').first&.content.to_s
  end

  def visibility
    if holding_status == 'Publicly available'
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    elsif holding_location == 'Personal Collection'
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    else
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    end
  end

  def rights_statement
    'http://rightsstatements.org/vocab/InC/1.0/'
  end

  def multi_volume?
    items.size > 1
  end

  def collections
    return ['libmus_personal'] if location == 'Personal Collection'
    []
  end

  private

    def items
      @items ||= @variations.xpath('/ScoreAccessPage/RecordSet/Container/Structure/Item')
    end

    def parse
      @files = []
      @variations.xpath('//FileInfos/FileInfo').each do |file|
        @files << file_hash(file)
      end
      @thumbnail_path = @files.first[:path]

      # assign structure hash and update files array with titles
      @file_index = 0
      if multi_volume?
        @volumes = []
        @file_start = 0
        items.each do |item|
          volume = {}
          volume[:title] = [item['label']]
          volume[:structure] = { nodes: structure_to_array(item) }
          volume[:files] = @files[@file_start, @file_index - @file_start]
          @file_start = @file_index
          @volumes << volume
        end
      else
        @structure = { nodes: structure_to_array(items.first) }
      end
    end

    # builds structure hash AND update file list with titles
    def structure_to_array(xml_node)
      array = []
      xml_node.xpath('child::*').each do |child|
        c = {}
        if child.name == 'Div'
          c[:label] = child['label']
          c[:nodes] = structure_to_array(child)
        elsif child.name == 'Chunk'
          c[:label] = child['label']
          c[:proxy] = @files[@file_index][:id]

          @files[@file_index][:attributes][:title] = [child['label']]
          @file_index += 1
        end
        array << c
      end
      array
    end

    def file_hash(file_node)
      values_hash = {}
      values_hash[:id] = filename(file_node)
      values_hash[:mime_type] = 'image/tiff'
      values_hash[:path] = '/tmp/ingest/' + values_hash[:id]
      values_hash[:file_opts] = {}
      values_hash[:attributes] = file_attributes(file_node, values_hash.dup)
      values_hash
    end

    def filename(file_node)
      normalized = file_node.xpath('FileName').first&.content.to_s.downcase.sub(/\.\w{3,4}/, '')
      root, volume, page = normalized.split('-')
      "#{root}-#{volume}-#{page.rjust(4, '0')}.tif"
    end

    def file_attributes(_file_node, values_hash)
      att_hash = {}
      att_hash[:title] = ['TITLE MISSING'] # replaced later
      att_hash[:source_metadata_identifier] = values_hash[:id].gsub(/\.\w{3,4}$/, '').upcase
      att_hash
    end
end
# rubocop:enable RSpec/DescribeClass
