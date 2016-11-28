class User < ActiveRecord::Base
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Curation Concerns behaviors.
  include CurationConcerns::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles
  # include Sufia::UserUsageStats
  include ::IuUserRoles

  # Enable ADS group lookup
  include LDAPGroupsLookup::Behavior
  alias_attribute :ldap_lookup_key, :username

  if Blacklight::Utils.needs_attr_accessible?

    attr_accessible :email, :password, :password_confirmation
  end
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  devise :omniauthable, omniauth_providers: [:cas]

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def to_param
    id
  end

  def groups
    g = roles.map(&:name)
    if Plum.config[:authorized_ldap_groups].blank?
      g += ['registered'] unless new_record? || guest?
    else
      g += ['registered'] if music_patron?
    end
    g
  end

  def authorized_ldap_member?(force_update = nil)
    if force_update == :force || authorized_membership_updated_at.nil? || authorized_membership_updated_at < Time.now - 1.day
      groups = Plum.config[:authorized_ldap_groups] || []
      self.authorized_membership = member_of_ldap_group?(groups)
      self.authorized_membership_updated_at = Time.now
      save
    end
    authorized_membership
  end

  def self.from_omniauth(access_token)
    User.where(provider: access_token.provider, uid: access_token.uid).first_or_create do |user|
      user.uid = access_token.uid
      user.provider = access_token.provider
      user.username = access_token.uid
      user.email = "#{access_token.uid}@iu.edu"
    end
  end
end
