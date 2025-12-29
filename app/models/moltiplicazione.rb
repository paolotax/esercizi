# frozen_string_literal: true

class Moltiplicazione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Parseable

  self.table_name = "moltiplicazioni"

  # Accessors per il campo JSON data
  store_accessor :data, :multiplicand, :multiplier, :title,
                 :show_exercise, :show_multiplicand_multiplier, :show_solution,
                 :show_toolbar, :show_partial_products, :show_carry, :show_labels

  # DSL Parseable
  parseable operator: /[x*×]/i, fields: [:multiplicand, :multiplier]
end
