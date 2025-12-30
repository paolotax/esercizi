class Pagina < ApplicationRecord
  include Searchable
  include Accessible

  # Associazioni
  belongs_to :account, optional: true
  belongs_to :disciplina

  # Validazioni
  validates :numero, presence: true
  validates :slug, presence: true, uniqueness: true

  # Scopes
  default_scope { order(:posizione, :numero) }

  scope :accessible_by, ->(user) {
    return all if user.admin?

    user_recipients = [ user, user.account ]

    pagina_ids = Share.active.where(shareable_type: "Pagina", recipient: user_recipients).select(:shareable_id)
    disciplina_ids = Share.active.where(shareable_type: "Disciplina", recipient: user_recipients).select(:shareable_id)
    volume_ids = Share.active.where(shareable_type: "Volume", recipient: user_recipients).select(:shareable_id)
    corso_ids = Share.active.where(shareable_type: "Corso", recipient: user_recipients).select(:shareable_id)

    where(id: pagina_ids)
      .or(where(disciplina_id: disciplina_ids))
      .or(where(disciplina_id: Disciplina.where(volume_id: volume_ids)))
      .or(where(disciplina_id: Disciplina.where(volume_id: Volume.where(corso_id: corso_ids))))
  }

  # Delegazioni
  delegate :volume, to: :disciplina
  delegate :corso, to: :disciplina

  # Callbacks
  before_validation :genera_slug, if: -> { slug.blank? }

  def accessible_by?(user)
    return false unless user
    return true if user.admin?
    return true if shared_with?(user)
    return true if disciplina.shared_with?(user)
    return true if disciplina.volume.shared_with?(user)
    return true if disciplina.volume.corso.shared_with?(user)

    false
  end

  def search_record_attributes
    {
      pagina_id: id,
      disciplina_id: disciplina_id,
      volume_id: disciplina&.volume_id,
      title: titolo,
      content: build_search_content
    }
  end

  private

  def build_search_content
    parts = [
      sottotitolo,
      "Pagina #{numero}",
      disciplina&.nome,
      disciplina&.volume&.nome,
      disciplina&.volume&.corso&.nome,
      disciplina&.volume&.classe ? "Classe #{disciplina.volume.classe}" : nil
    ]
    parts.compact.join(" ")
  end

  def genera_slug
    return unless disciplina && numero

    codice_corso = disciplina.volume.corso.codice
    classe_volume = disciplina.volume.classe
    codice_disciplina = disciplina.codice
    numero_pagina = numero.to_s.rjust(3, "0")

    self.slug = "#{codice_corso}#{classe_volume}_#{codice_disciplina}_p#{numero_pagina}"
  end
end
