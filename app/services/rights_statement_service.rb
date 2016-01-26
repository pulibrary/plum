module RightsStatementService
  include RightsService

  def self.definition(id)
    obj = RightsService.authority.find(id)
    obj['definition'] || ''
  end

  def self.valid_statements
    RightsService.authority.all.map { |hash| hash['id'] }
  end
end
