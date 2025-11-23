class EsercizioTemplate < ApplicationRecord
  # Serializzazione JSON per SQLite
  serialize :default_config, coder: JSON, type: Hash

  # Validazioni
  validates :name, presence: true
  validates :category, presence: true

  # Scopes
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :most_used, -> { order(usage_count: :desc) }

  # Metodi pubblici
  def increment_usage!
    increment!(:usage_count)
  end

  def create_esercizio(attributes = {})
    esercizio = Esercizio.new(attributes)
    esercizio.content = default_config.deep_dup if default_config.present?
    increment_usage! if esercizio.save
    esercizio
  end

  # Categorie predefinite per i template
  CATEGORIES = [
    'Base',
    'Intermedio',
    'Avanzato',
    'Verifica',
    'Esercitazione',
    'Compiti'
  ].freeze

  def self.categories
    CATEGORIES
  end
end
