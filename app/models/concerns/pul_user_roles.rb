# frozen_string_literal: true
module PulUserRoles
  extend ActiveSupport::Concern

  def ephemera_editor?
    roles.where(name: 'ephemera_editor').exists?
  end

  def image_editor?
    roles.where(name: 'image_editor').exists?
  end

  def completer?
    roles.where(name: 'completer').exists?
  end

  def editor?
    roles.where(name: 'editor').exists?
  end

  def fulfiller?
    roles.where(name: 'fulfiller').exists?
  end

  def curator?
    roles.where(name: 'curator').exists?
  end

  def campus_patron?
    persisted? && provider == "cas"
  end

  def anonymous?
    !persisted?
  end
end
