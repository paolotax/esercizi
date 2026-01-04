class User < ApplicationRecord
  include Role, Named, Avatar, Admin

  belongs_to :account
  belongs_to :identity, optional: true

  has_many :created_esercizi, class_name: "Esercizio", foreign_key: :creator_id, dependent: :nullify
  has_many :esercizio_attempts, dependent: :nullify
  has_many :taught_classi, class_name: "Classe", foreign_key: :teacher_id, dependent: :destroy
  has_many :classe_memberships, dependent: :destroy
  has_many :classi, through: :classe_memberships

  scope :active, -> { where(active: true) }

  validates :name, presence: true

  def deactivate
    update!(active: false, identity: nil)
  end

  def setup?
    name.present? && name != identity&.email_address&.split("@")&.first
  end

  def verified?
    verified_at.present?
  end

  def verify
    update!(verified_at: Time.current) unless verified?
  end
end
