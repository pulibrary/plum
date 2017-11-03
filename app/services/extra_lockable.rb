module ExtraLockable
  extend ActiveSupport::Concern
  include CurationConcerns::Lockable

  included do
    class_attribute :lock_id_attribute
    self.lock_id_attribute = :id

    # TODO: Handle when id is nil or not defined.
    def lock_id
      ident = try(lock_id_attribute)
      raise ArgumentError, "lock id attribute cannot be blank" if ident.blank?
      "lock_#{ident}"
    end

    # Provides a way to pass options to the underlying Redlock client.
    def lock(key = lock_id, options = {})
      ttl = options.delete(:ttl) || CurationConcerns.config.lock_time_to_live
      if block_given?
        lock_manager.client.lock(key, ttl, options, &Proc.new)
      else
        lock_manager.client.lock(key, ttl, options)
      end
    end

    def lock?(key = lock_id)
      acquire_lock_for(key) { nil }
      Rails.logger.info "ExtraLockable: No lock found for key: #{key}"
      return false
    rescue CurationConcerns::LockManager::UnableToAcquireLockError
      Rails.logger.info "ExtraLockable: Found a lock for key: #{key}"
      return true
    end

    def unlock(lock_info)
      lock_manager.client.unlock lock_info
    end
  end
end
