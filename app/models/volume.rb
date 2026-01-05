class Volume < ApplicationRecord
  include Accessible

  # Associazioni
  belongs_to :account, optional: true
  belongs_to :corso
  has_many :discipline, dependent: :destroy

  # Validazioni
  validates :nome, presence: true
  validates :classe, inclusion: { in: 1..5, allow_nil: true }

  # Scopes
  default_scope { order(:posizione, :classe) }

  scope :accessible_by, ->(user) {
    return all if user&.admin?

    return with_public_pages if user.nil?

    user_recipients = [ user, user.account ]

    volume_ids = Share.active.where(shareable_type: "Volume", recipient: user_recipients).select(:shareable_id)
    corso_ids = Share.active.where(shareable_type: "Corso", recipient: user_recipients).select(:shareable_id)

    where(id: volume_ids)
      .or(where(corso_id: corso_ids))
  }

  scope :with_public_pages, -> {
    joins(discipline: :pagine)
      .where(pagine: { public: true })
      .distinct
  }

  def accessible_by?(user)
    return false unless user
    return true if user.admin?
    return true if shared_with?(user)
    return true if corso.shared_with?(user)

    false
  end
end
