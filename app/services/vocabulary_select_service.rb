# frozen_string_literal: true
class VocabularySelectService
  attr_reader :authority

  def initialize(authority_name)
    @authority = Qa::Authorities::Local.subauthority_for(authority_name)
  end

  def select_all_options
    authority.all.map do |vocab|
      Option.for(vocab)
    end
  end

  class Option
    def self.for(vocab)
      case vocab[:type]
      when "Vocabulary"
        VocabularyOption.new(vocab)
      else
        Option.new(vocab)
      end
    end

    class VocabularyOption < Option
      def child_terms
        VocabularySelectService.new(label).select_all_options
      end
    end
    attr_reader :element
    def initialize(element)
      @element = element
    end

    def label
      element[:label]
    end

    def id
      element[:id]
    end

    def child_terms
      []
    end
  end
end
