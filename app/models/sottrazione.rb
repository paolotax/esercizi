# frozen_string_literal: true

class Sottrazione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Parseable
  include Sottrazione::Calculation

  self.table_name = "sottrazioni"

  # Accessors per il campo JSON data
  store_accessor :data, :minuend, :subtrahend, :title,
                 :show_exercise, :show_minuend_subtrahend, :show_solution,
                 :show_toolbar, :show_borrow, :show_labels

  # Reset dei calcoli quando cambiano i dati
  after_save :reset_calculations!

  # DSL Parseable
  parseable operator: /[-]/, fields: [ :minuend, :subtrahend ]

  # Override: risultato non può essere negativo
  def self.valid_operation?(parsed)
    parsed[:minuend].to_f >= parsed[:subtrahend].to_f
  end
end
