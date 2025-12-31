# frozen_string_literal: true

class Divisione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Parseable
  include Divisione::Calculation
  include Divisione::GridRenderable

  self.table_name = "divisioni"

  # Accessors per il campo JSON data
  store_accessor :data, :dividend, :divisor, :title,
                 :show_exercise, :show_dividend_divisor, :show_solution,
                 :show_toolbar, :show_steps, :extra_zeros, :grid_style_value

  # Lista degli attributi divisione (per distinguere da attributi AR)
  DIVISIONE_ATTRS = %i[dividend divisor title show_exercise show_dividend_divisor
                       show_solution show_toolbar show_steps extra_zeros grid_style_value].freeze

  # Opzioni generiche che vengono normalizzate o mappate
  GENERIC_ATTRS = %i[show_operands layout grid_style].freeze

  # Override initialize per accettare sia formato AR che formato Renderer
  def initialize(attributes = nil)
    if attributes.is_a?(Hash)
      normalized = self.class.normalize_options(attributes.slice(*GENERIC_ATTRS))
      attrs_without_generic = attributes.except(*GENERIC_ATTRS).merge(normalized)

      div_attrs = attrs_without_generic.slice(*DIVISIONE_ATTRS)
      other_attrs = attrs_without_generic.except(*DIVISIONE_ATTRS)

      if div_attrs.any? && !attributes.key?(:data)
        other_attrs[:data] = div_attrs
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
  parseable operator: /[\/÷:]/, fields: [ :dividend, :divisor ]

  # Override: divisore non può essere zero
  def self.valid_operation?(parsed)
    parsed[:divisor].to_f != 0
  end

  # Istanza: restituisce self (il model È il renderer)
  def to_renderer
    self
  end

  # Alias per compatibilità
  Renderer = self
end
