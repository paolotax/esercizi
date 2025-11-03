class Disciplina < ApplicationRecord
  # Associazioni
  belongs_to :volume
  has_many :pagine, dependent: :destroy

  # Validazioni
  validates :nome, presence: true
  validates :codice, presence: true

  # Scopes
  default_scope { order(:nome) }

  # Delegazioni
  delegate :corso, to: :volume
end
