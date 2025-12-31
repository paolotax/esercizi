# frozen_string_literal: true

class Moltiplicazione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Parseable
  include Moltiplicazione::Calculation
  include Moltiplicazione::GridRenderable

  self.table_name = "moltiplicazioni"

  # Accessors per il campo JSON data
  store_accessor :data, :multiplicand, :multiplier, :title,
                 :show_exercise, :show_multiplicand_multiplier, :show_solution,
                 :show_toolbar, :show_partial_products, :show_carry, :show_labels,
                 :grid_style_value

  # Lista degli attributi moltiplicazione (per distinguere da attributi AR)
  MOLTIPLICAZIONE_ATTRS = %i[multiplicand multiplier title show_exercise show_multiplicand_multiplier
                             show_solution show_toolbar show_partial_products show_carry show_labels
                             grid_style_value].freeze

  # Opzioni generiche che vengono normalizzate o mappate
  GENERIC_ATTRS = %i[show_operands show_steps layout grid_style].freeze

  # Override initialize per accettare sia formato AR che formato Renderer
  def initialize(attributes = nil)
    if attributes.is_a?(Hash)
      normalized = self.class.normalize_options(attributes.slice(*GENERIC_ATTRS))
      attrs_without_generic = attributes.except(*GENERIC_ATTRS).merge(normalized)

      molt_attrs = attrs_without_generic.slice(*MOLTIPLICAZIONE_ATTRS)
      other_attrs = attrs_without_generic.except(*MOLTIPLICAZIONE_ATTRS)

      if molt_attrs.any? && !attributes.key?(:data)
        other_attrs[:data] = molt_attrs
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
  parseable operator: /[x*×]/i, fields: [ :multiplicand, :multiplier ]

  # Istanza: restituisce self (il model È il renderer)
  def to_renderer
    self
  end

  # Alias per compatibilità
  Renderer = self
end
