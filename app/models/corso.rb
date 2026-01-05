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
    return all if user&.admin?

    return with_public_pages if user.nil?

    user_recipients = [ user, user.account ]
    corso_ids = Share.active.where(shareable_type: "Corso", recipient: user_recipients).select(:shareable_id)

    where(id: corso_ids)
  }

  scope :with_public_pages, -> {
    joins(volumi: { discipline: :pagine })
      .where(pagine: { public: true })
      .distinct
  }

  def accessible_by?(user)
    return false unless user
    return true if user.admin?

    shared_with?(user)
  end
end
