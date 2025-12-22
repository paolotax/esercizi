class Volume < ApplicationRecord
  # Associazioni
  belongs_to :account, optional: true
  belongs_to :corso
  has_many :discipline, dependent: :destroy

  # Validazioni
  validates :nome, presence: true
  validates :classe, inclusion: { in: 1..5, allow_nil: true }

  # Scopes
  default_scope { order(:posizione, :classe) }
end
