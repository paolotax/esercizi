# frozen_string_literal: true

module Publishable
  extend ActiveSupport::Concern

  included do
    enum :status, { draft: 0, private_status: 1, shared: 2, published: 3 }, default: :draft

    scope :drafts, -> { where(status: :draft) }
    scope :published, -> { where(status: :published) }
    scope :shared_or_published, -> { where(status: [:shared, :published]) }

    scope :visible_to, ->(user) {
      return published if user.nil?

      where(status: :published)
        .or(where(creator_id: user.id))
        .or(where(id: joins(:shares).where(shares: { recipient_type: "User", recipient_id: user.id }).select(:id)))
        .or(where(id: joins(:shares).where(shares: { recipient_type: "Account", recipient_id: user.account_id }).select(:id)))
    }
  end

  def publish!
    update!(status: :published, published_at: Time.current)
  end

  def unpublish!
    update!(status: :draft, published_at: nil)
  end

  def make_private!
    update!(status: :private_status)
  end

  def make_shared!
    update!(status: :shared)
  end

  def visible_to?(user)
    return true if published?
    return false if user.nil?
    return true if creator_id == user.id
    return true if respond_to?(:shares) && shares.exists?(recipient_type: "User", recipient_id: user.id)
    return true if respond_to?(:shares) && user.account_id && shares.exists?(recipient_type: "Account", recipient_id: user.account_id)
    false
  end

  def editable_by?(user)
    return false if user.nil?
    return true if creator_id == user.id
    return true if respond_to?(:shares) && shares.exists?(recipient_type: "User", recipient_id: user.id, permission: [:edit, :admin])
    return true if respond_to?(:shares) && user.account_id && shares.exists?(recipient_type: "Account", recipient_id: user.account_id, permission: [:edit, :admin])
    false
  end
end
