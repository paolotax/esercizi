class Corso < ApplicationRecord
  # Associazioni
  has_many :volumi, dependent: :destroy

  # Validazioni
  validates :nome, presence: true
  validates :codice, presence: true, uniqueness: true

  # Scopes
  default_scope { order(:nome) }
end
