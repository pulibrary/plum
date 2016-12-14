module StateBehavior
  extend ActiveSupport::Concern

  included do
    before_update :check_state

    validates_with StateValidator

    def check_state
      return unless state_changed?
      complete_record if state == 'complete'
      ReviewerMailer.notify(id, state).deliver_later
    end

    private

      def complete_record
        if identifier
          update_ezid
        else
          self.identifier = Ezid::Identifier.mint(ezid_metadata).id
        end
      end

      def ezid_metadata
        {
          dc_publisher: 'Princeton University Library',
          dc_title: title.join('; '),
          dc_type: 'Text',
          target: ManifestBuilder::ManifestHelper.new.polymorphic_url(self)
        }
      end

      def update_ezid
        return if Ezid::Client.config.user == "apitest"
        Ezid::Identifier.modify(identifier, ezid_metadata)
      end
  end
end
