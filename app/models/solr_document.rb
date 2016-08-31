# -*- encoding : utf-8 -*-
class SolrDocument
  include Blacklight::Solr::Document
  # Adds CurationConcerns behaviors to the SolrDocument.
  include CurationConcerns::SolrDocumentBehavior

  # self.unique_key = 'id'
  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)
  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension(Hydra::ContentNegotiation)

  def date_created
    self[Solrizer.solr_name('date_created')]
  end

  def state
    Array(self[Solrizer.solr_name("state")]).first
  end

  def type
    self['has_model_ssim'].first
  end

  def viewing_hint
    Array(self[Solrizer.solr_name("viewing_hint")]).first
  end

  def viewing_direction
    Array(self[Solrizer.solr_name("viewing_direction")]).first
  end

  def identifier
    Array(self[Solrizer.solr_name("identifier")]).first
  end

  def workflow_note
    self[Solrizer.solr_name('workflow_note')]
  end

  def logical_order
    @logical_order ||=
      begin
        JSON.parse(self[Solrizer.solr_name("logical_order", :stored_searchable)].first)
      rescue
        {}
      end
  end

  def exhibit_id
    self[Solrizer.solr_name('exhibit_id')]
  end

  def rights_statement
    self[Solrizer.solr_name('rights_statement')]
  end

  def rights_note
    self[Solrizer.solr_name('rights_note')]
  end

  def holding_location
    self[Solrizer.solr_name('holding_location')]
  end

  def language
    self[Solrizer.solr_name('language')]
  end

  def source_metadata_identifier
    self[Solrizer.solr_name('source_metadata_identifier')]
  end

  def ocr_language
    ocr_lang = self[Solrizer.solr_name('ocr_language')]
    return ocr_lang unless ocr_lang.nil?
    return language if language && Tesseract.languages.keys.include?(language.first.to_sym)
  end

  def thumbnail_id
    Array(self[Solrizer.solr_name('hasRelatedImage', :symbol)]).first
  end

  def height
    self[Solrizer.solr_name('height', Solrizer::Descriptor.new(:integer, :stored))]
  end

  def width
    self[Solrizer.solr_name('width', Solrizer::Descriptor.new(:integer, :stored))]
  end

  def collection
    self[Solrizer.solr_name('member_of_collections', :symbol)]
  end

  def method_missing(meth_name, *args, &block)
    if ScannedResource.properties.values.map(&:term).include?(meth_name)
      self[Solrizer.solr_name(meth_name.to_s)]
    elsif ScannedResource.properties.values.map { |x| "#{x.term}_literals".to_sym }.include?(meth_name)
      Array(self[Solrizer.solr_name(meth_name.to_s, :symbol)]).map do |x|
        if x.start_with?("{")
          JSON.parse(x)
        else
          x
        end
      end
    else
      super
    end
  end

  def to_model
    @to_model ||= DummyModel.new(self['has_model_ssim'].first, id)
  end

  class DummyModel
    attr_reader :class_name, :id
    delegate :model_name, to: :klass
    def initialize(class_name, id)
      @class_name = class_name
      @id = id
    end

    def to_partial_path
      klass._to_partial_path
    end

    def persisted?
      true
    end

    def to_param
      id
    end

    private

      def klass
        @klass ||= class_name.constantize
      end
  end
end
