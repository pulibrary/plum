module RightsStatementService
  include RightsService

  def self.definition(id)
    obj = RightsService.authority.find(id)
    obj['definition'] || ''
  end

  def self.valid_statements
    RightsService.authority.all.map { |hash| hash['id'] }
  end

  def self.notable?(id)
    id = id.first if id.is_a?(Array)
    obj = RightsService.authority.find(id)
    obj['notable'] == true
  end
end
