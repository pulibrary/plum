# frozen_string_literal: true
require 'rails-controller-testing'
RSpec.configure do |config|
  config.include Rails::Controller::Testing::TestProcess, type: :controller
  config.include Rails::Controller::Testing::TemplateAssertions, type: :controller

  config.include Rails::Controller::Testing::TemplateAssertions, type: :request
  config.include Rails::Controller::Testing::Integration, type: :request
  config.include Rails::Controller::Testing::TestProcess, type: :request

  config.include Rails::Controller::Testing::TemplateAssertions, type: :view
end
