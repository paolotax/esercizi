# frozen_string_literal: true

class Share < ApplicationRecord
  belongs_to :shareable, polymorphic: true
  belongs_to :granted_by, class_name: "User", optional: true

  delegated_type :recipient, types: %w[Account User]

  enum :permission, { view: 0, edit: 1, admin: 2 }, default: :view

  validates :recipient_type, :recipient_id, presence: true
  validates :shareable_id, uniqueness: {
    scope: [:shareable_type, :recipient_type, :recipient_id],
    message: "già condiviso con questo destinatario"
  }

  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }
  scope :for_user, ->(user) { where(recipient_type: "User", recipient_id: user.id) }
  scope :for_account, ->(account) { where(recipient_type: "Account", recipient_id: account.id) }

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def active?
    !expired?
  end

  def can_edit?
    edit? || admin?
  end

  def can_admin?
    admin?
  end
end
