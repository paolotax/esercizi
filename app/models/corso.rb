class Corso < ApplicationRecord
  include Accessible

  # Associazioni
  belongs_to :account, optional: true
  has_many :volumi, dependent: :destroy

  # Validazioni
  validates :nome, presence: true
  validates :codice, presence: true, uniqueness: true

  # Scopes
  default_scope { order(:nome) }

  scope :accessible_by, ->(user) {
    return all if user.admin?

    user_recipients = [user, user.account]
    corso_ids = Share.active.where(shareable_type: "Corso", recipient: user_recipients).select(:shareable_id)

    where(id: corso_ids)
  }

  def accessible_by?(user)
    return false unless user
    return true if user.admin?

    shared_with?(user)
  end
end
