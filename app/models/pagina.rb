class Pagina < ApplicationRecord
  # Associazioni
  belongs_to :disciplina

  # Validazioni
  validates :numero, presence: true
  validates :slug, presence: true, uniqueness: true

  # Scopes
  default_scope { order(:posizione, :numero) }

  # Delegazioni
  delegate :volume, to: :disciplina
  delegate :corso, to: :disciplina

  # Callbacks
  before_validation :genera_slug, if: -> { slug.blank? }

  private

  def genera_slug
    return unless disciplina && numero

    codice_corso = disciplina.volume.corso.codice
    classe_volume = disciplina.volume.classe
    codice_disciplina = disciplina.codice
    numero_pagina = numero.to_s.rjust(3, '0')

    self.slug = "#{codice_corso}#{classe_volume}_#{codice_disciplina}_p#{numero_pagina}"
  end
end
