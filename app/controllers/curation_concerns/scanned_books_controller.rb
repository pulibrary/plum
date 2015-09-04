# Generated via
#  `rails generate curation_concerns:work ScannedBook`

class CurationConcerns::ScannedBooksController < ApplicationController
  include CurationConcerns::CurationConcernController
  set_curation_concern_type ScannedBook

  def curation_concern
    if needs_update?(@curation_concern)
      decorated_concern
    else
      @curation_concern
    end
  end

  private

    def decorated_concern
      decorator.new(@curation_concern)
    end

    def decorator
      UpdatesMetadata
    end

    def needs_update?(_result)
      params[:action] == "create"
    end
end
