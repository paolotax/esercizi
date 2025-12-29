# frozen_string_literal: true

class Divisione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Parseable

  self.table_name = "divisioni"

  # Accessors per il campo JSON data
  store_accessor :data, :dividend, :divisor, :title,
                 :show_exercise, :show_dividend_divisor, :show_solution,
                 :show_toolbar, :show_steps

  # DSL Parseable
  parseable operator: /[\/÷:]/, fields: [:dividend, :divisor]

  # Override: divisore non può essere zero
  def self.valid_operation?(parsed)
    parsed[:divisor].to_f != 0
  end
end
