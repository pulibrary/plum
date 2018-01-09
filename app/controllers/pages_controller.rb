# frozen_string_literal: true
class PagesController < ApplicationController
  def robots
    respond_to :text
    expires_in 6.hours, public: true
  end
end
