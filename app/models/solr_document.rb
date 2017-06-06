# -*- encoding : utf-8 -*-
class SolrDocument
  include Blacklight::Solr::Document
  # Adds GeoWorks behaviors to the SolrDocument.
  include GeoWorks::SolrDocumentBehavior

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior
  include SolrDates
  include SolrGeoMetadata
  include SolrTechnicalMetadata

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

  def type
    self['has_model_ssim'].first
  end

  def logical_order
    @logical_order ||=
      begin
        JSON.parse(self[Solrizer.solr_name("logical_order", :stored_searchable)].first)
      rescue
        {}
      end
  end

  def ocr_language
    ocr_lang = self[Solrizer.solr_name('ocr_language')]
    return ocr_lang unless ocr_lang.nil?
    return language if language && Tesseract.languages.keys.include?(language.first.to_sym)
  end

  def ocr_text
    Array(self[Solrizer.solr_name("full_text")]).first
  end

  def collection
    self[Solrizer.solr_name('member_of_collections', :symbol)]
  end

  def title_or_label
    return label if title.blank?
    Array(title).join(', ')
  end

  def ephemera_project_name
    Array(self[Solrizer.solr_name('ephemera_project_name', :symbol)]).first
  end

  def method_missing(meth_name, *args, &block)
    attribute = Attribute.for(meth_name, self)
    return attribute.value if attribute.valid?
    super
  end

  class Attribute
    class_attribute :single_valued_fields
    self.single_valued_fields = [
      :viewing_hint,
      :viewing_direction,
      :identifier,
      :barcode,
      :ephemera_project,
      :source_jsonld,
      :folder_number
    ]

    def self.for(property, document)
      if property.to_s.end_with?("_literals")
        LiteralAttribute.new(property, document)
      elsif single_valued_fields.include?(property.to_sym)
        SingleAttribute.new(property, document)
      else
        new(property.to_sym, document)
      end
    end

    attr_reader :property, :document
    def initialize(property, document)
      @property = property
      @document = document
    end

    def valid?
      all_terms.include?(property)
    end

    def value
      document[Solrizer.solr_name(property)] || document[Solrizer.solr_name(property, :symbol)]
    end

    def all_terms
      (Hyrax.config.curation_concerns + [Collection]).map { |x| x.properties.values.map(&:term) }.inject(:+)
    end
  end

  class SingleAttribute < Attribute
    def value
      Array(super).first
    end
  end

  class LiteralAttribute < Attribute
    def value
      Array(super).map do |x|
        if x.start_with?("{")
          JSON.parse(x)
        else
          x
        end
      end
    end

    def all_terms
      super.map do |term|
        "#{term}_literals".to_sym
      end
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

    def to_global_id
      URI::GID.build app: GlobalID.app, model_name: model_name.name, model_id: @id
    end

    private

      def klass
        @klass ||= class_name.constantize
      end
  end
end
