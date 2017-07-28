module DefaultReadGroups
  extend ActiveSupport::Concern
  included do
    def read_groups
      super.empty? ? Ability.universal_readers : super
    end
  end
end
