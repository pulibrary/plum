# frozen_string_literal: true
class User < ActiveRecord::Base
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  include Hyrax::UserUsageStats
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Curation Concerns behaviors.
  include Hyrax::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles
  # include Sufia::UserUsageStats
  include ::PulUserRoles

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

  def self.from_omniauth(access_token)
    User.where(provider: access_token.provider, uid: access_token.uid).first_or_create do |user|
      user.uid = access_token.uid
      user.provider = access_token.provider
      user.username = access_token.uid
      user.email = "#{access_token.uid}@princeton.edu"
    end
  end
end
