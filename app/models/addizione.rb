# frozen_string_literal: true

class Addizione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Parseable
  include Addizione::Calculation

  self.table_name = "addizioni"

  # Accessors per il campo JSON data
  store_accessor :data, :addends, :operator, :title,
                 :show_exercise, :show_addends, :show_solution,
                 :show_toolbar, :show_carry, :show_labels, :show_addend_indices

  # Reset dei calcoli quando cambiano i dati
  after_save :reset_calculations!

  # DSL Parseable
  parseable operator: /[+]/, fields: [ :addends ]

  # Override: Addizione supporta N addendi
  def self.parse_result(parts)
    { addends: parts }
  end
end
