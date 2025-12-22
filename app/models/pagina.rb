class Pagina < ApplicationRecord
  include Searchable

  # Associazioni
  belongs_to :account, optional: true
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
