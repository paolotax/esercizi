# frozen_string_literal: true

class Addizione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Parseable
  include Addizione::Calculation
  include Addizione::GridRenderable

  self.table_name = "addizioni"

  # Accessors per il campo JSON data
  store_accessor :data, :addends, :operator, :title,
                 :show_exercise, :show_addends, :show_solution,
                 :show_toolbar, :show_carry, :show_labels, :show_addend_indices,
                 :grid_style_value, :example_type

  # Lista degli attributi addizione (per distinguere da attributi AR)
  ADDIZIONE_ATTRS = %i[addends operator title show_exercise show_addends show_solution
                       show_toolbar show_carry show_labels show_addend_indices grid_style_value
                       example_type].freeze

  # Opzioni generiche che vengono normalizzate o mappate
  GENERIC_ATTRS = %i[show_operands layout grid_style].freeze

  # Override initialize per accettare sia formato AR che formato Renderer
  # Renderer: Addizione.new(addends: [1,2,3], operator: "+")
  # AR:       Addizione.new(data: { addends: [1,2,3] })
  def initialize(attributes = nil)
    if attributes.is_a?(Hash)
      # Prima normalizza le opzioni generiche
      normalized = self.class.normalize_options(attributes.slice(*GENERIC_ATTRS))
      attrs_without_generic = attributes.except(*GENERIC_ATTRS).merge(normalized)

      addizione_attrs = attrs_without_generic.slice(*ADDIZIONE_ATTRS)
      other_attrs = attrs_without_generic.except(*ADDIZIONE_ATTRS)

      if addizione_attrs.any? && !attributes.key?(:data)
        # Formato Renderer: keyword args diretti
        other_attrs[:data] = addizione_attrs
        super(other_attrs)
      else
        super(attrs_without_generic)
      end
    else
      super
    end
  end

  # Reset dei calcoli quando cambiano i dati
  after_save :reset_calculations!

  # DSL Parseable
  parseable operator: /[+]/, fields: [ :addends ]

  # Override: Addizione supporta N addendi
  def self.parse_result(parts)
    { addends: parts }
  end

  # Istanza: restituisce self (il model È il renderer)
  def to_renderer
    self
  end

  # Alias per compatibilità: Addizione::Renderer ora punta ad Addizione
  Renderer = self
end
