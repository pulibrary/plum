Rails.configuration.assets.paths.reject! do |path|
  path.to_s.include?('rails-assets-jquery') && !path.to_s.include?('rails-assets-jqueryui-timepicker')
end
