class RightsStatementService < Hyrax::LicenseService
  def definition(id)
    obj = authority.find(id)
    obj['definition'] || ''
  end

  def valid_statements
    authority.all.map { |hash| [hash['id']] }
  end

  def notable?(id)
    id = id.first if id.is_a?(Array)
    obj = authority.find(id)
    obj['notable'] == true
  end

  def select_options
    authority.all.map { |term| [term[:label], term[:id]] }
  end
end
