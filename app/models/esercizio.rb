class Esercizio < ApplicationRecord
  include Shareable
  include Searchable

  # Serializzazione JSON per SQLite
  serialize :tags, coder: JSON, type: Array

  # Callbacks per inizializzare i campi JSON
  after_initialize :ensure_defaults

  # Associazioni
  belongs_to :account, optional: true
  belongs_to :creator, class_name: "User", optional: true
  has_many :esercizio_attempts, dependent: :destroy
  has_many :questions, -> { ordered }, dependent: :destroy

  # Validazioni
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :share_token, uniqueness: true, allow_nil: true

  # Callbacks
  before_validation :generate_slug, on: :create
  before_create :generate_share_token

  # Scopes
  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :draft, -> { where(published_at: nil) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_difficulty, ->(difficulty) { where(difficulty: difficulty) if difficulty.present? }
  # Per SQLite, dobbiamo cercare nel JSON serializzato
  scope :with_tag, ->(tag) { where("tags LIKE ?", "%#{tag}%") if tag.present? }

  # Metodi pubblici
  def published?
    published_at.present? && published_at <= Time.current
  end

  def draft?
    !published?
  end

  def publish!
    update(published_at: Time.current) if draft?
  end

  def unpublish!
    update(published_at: nil) if published?
  end

  def increment_views!
    increment!(:views_count)
  end

  def search_record_attributes
    {
      pagina_id: nil,
      disciplina_id: nil,
      volume_id: nil,
      title: title,
      content: [
        description,
        category,
        tags&.join(" ")
      ].compact.join(" ")
    }
  end

  private

  def ensure_defaults
    self.tags ||= []
  end

  def generate_slug
    if title.present? && slug.blank?
      base_slug = title.parameterize
      counter = 1
      self.slug = base_slug

      while Esercizio.exists?(slug: self.slug)
        self.slug = "#{base_slug}-#{counter}"
        counter += 1
      end
    end
  end

  def generate_share_token
    self.share_token = SecureRandom.urlsafe_base64(8)

    while Esercizio.exists?(share_token: self.share_token)
      self.share_token = SecureRandom.urlsafe_base64(8)
    end
  end
end
