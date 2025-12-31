# frozen_string_literal: true

class Sottrazione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Parseable
  include Sottrazione::Calculation
  include Sottrazione::GridRenderable

  self.table_name = "sottrazioni"

  # Accessors per il campo JSON data
  store_accessor :data, :minuend, :subtrahend, :title,
                 :show_exercise, :show_minuend_subtrahend, :show_solution,
                 :show_toolbar, :show_borrow, :show_labels, :grid_style_value,
                 :example_type

  # Lista degli attributi sottrazione (per distinguere da attributi AR)
  SOTTRAZIONE_ATTRS = %i[minuend subtrahend title show_exercise show_minuend_subtrahend
                         show_solution show_toolbar show_borrow show_labels grid_style_value
                         example_type].freeze

  # Opzioni generiche che vengono normalizzate o mappate
  GENERIC_ATTRS = %i[show_operands show_carry layout grid_style].freeze

  # Override initialize per accettare sia formato AR che formato Renderer
  def initialize(attributes = nil)
    if attributes.is_a?(Hash)
      normalized = self.class.normalize_options(attributes.slice(*GENERIC_ATTRS))
      attrs_without_generic = attributes.except(*GENERIC_ATTRS).merge(normalized)

      sottrazione_attrs = attrs_without_generic.slice(*SOTTRAZIONE_ATTRS)
      other_attrs = attrs_without_generic.except(*SOTTRAZIONE_ATTRS)

      if sottrazione_attrs.any? && !attributes.key?(:data)
        other_attrs[:data] = sottrazione_attrs
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
  parseable operator: /[-]/, fields: [ :minuend, :subtrahend ]

  # Override: risultato non può essere negativo
  def self.valid_operation?(parsed)
    parsed[:minuend].to_f >= parsed[:subtrahend].to_f
  end

  # Istanza: restituisce self (il model È il renderer)
  def to_renderer
    self
  end

  # Alias per compatibilità
  Renderer = self
end
