# frozen_string_literal: true
# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
# use Rack::RubyProf, path: '/tmp/profile', printers: { ::RubyProf::CallStackPrinter => 'call_stack.html' }
