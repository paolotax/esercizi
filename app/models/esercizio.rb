# frozen_string_literal: true

class Esercizio < ApplicationRecord
  include Publishable
  include Shareable
  include Searchable

  serialize :tags, coder: JSON, type: Array

  belongs_to :account, optional: true
  belongs_to :creator, class_name: "User", optional: true

  has_many :questions, -> { ordered }, dependent: :destroy
  has_many :shares, as: :shareable, dependent: :destroy
  has_many :esercizio_attempts, dependent: :destroy

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :share_token, uniqueness: true, allow_nil: true

  before_validation :generate_slug, on: :create
  before_create :generate_share_token

  after_initialize :ensure_defaults

  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_difficulty, ->(difficulty) { where(difficulty: difficulty) if difficulty.present? }
  scope :with_tag, ->(tag) { where("tags LIKE ?", "%#{tag}%") if tag.present? }

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
