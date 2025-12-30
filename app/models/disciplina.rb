class Disciplina < ApplicationRecord
  include Accessible

  # Associazioni
  belongs_to :account, optional: true
  belongs_to :volume
  has_many :pagine, dependent: :destroy

  # Validazioni
  validates :nome, presence: true
  validates :codice, presence: true

  # Scopes
  default_scope { order(:nome) }

  scope :accessible_by, ->(user) {
    return all if user.admin?

    user_recipients = [ user, user.account ]

    disciplina_ids = Share.active.where(shareable_type: "Disciplina", recipient: user_recipients).select(:shareable_id)
    volume_ids = Share.active.where(shareable_type: "Volume", recipient: user_recipients).select(:shareable_id)
    corso_ids = Share.active.where(shareable_type: "Corso", recipient: user_recipients).select(:shareable_id)

    where(id: disciplina_ids)
      .or(where(volume_id: volume_ids))
      .or(where(volume_id: Volume.where(corso_id: corso_ids)))
  }

  # Delegazioni
  delegate :corso, to: :volume

  def accessible_by?(user)
    return false unless user
    return true if user.admin?
    return true if shared_with?(user)
    return true if volume.shared_with?(user)
    return true if volume.corso.shared_with?(user)

    false
  end
end
