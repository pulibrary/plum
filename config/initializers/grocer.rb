# frozen_string_literal: true
Grocer.configure do |conf|
  conf.export_dir = ENV['PLUM_EXPORT_DIR'] || Rails.root.join('tmp', 'export')
end
