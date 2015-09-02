# Generated via
#  `rails generate curation_concerns:work ScannedBook`

class CurationConcerns::ScannedBooksController < ApplicationController
  include CurationConcerns::CurationConcernController
  set_curation_concern_type ScannedBook
end
