# frozen_string_literal: true

class Moltiplicazione < ApplicationRecord
  include Questionable
  include GenericOptions

  self.table_name = "moltiplicazioni"

  # Accessors per il campo JSON data
  store_accessor :data, :multiplicand, :multiplier, :title,
                 :show_exercise, :show_multiplicand_multiplier, :show_solution,
                 :show_toolbar, :show_partial_products, :show_carry, :show_labels

  # Parse: estrae moltiplicando e moltiplicatore da stringa (es: "45x12" o "4,5x1,2")
  def self.parse(operation_string)
    return nil if operation_string.blank?

    # Supporta x, *, × come operatori
    match = operation_string.gsub(/\s+/, "").match(/^(\d+([.,]\d+)?)\s*[x*×]\s*(\d+([.,]\d+)?)$/i)
    return nil unless match

    multiplicand = match[1].gsub(",", ".")
    multiplier = match[3].gsub(",", ".")

    { multiplicand: multiplicand, multiplier: multiplier }
  end

  # Parse multiple: estrae da stringhe separate da ; o \n
  def self.parse_multiple(operations_string)
    return [] if operations_string.blank?

    operations_string
      .split(/[;\n]/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |op| parse(op) }
      .compact
  end

  # Factory: crea un Renderer da stringa operazione
  def self.build_renderer(operation_string, **options)
    parsed = parse(operation_string)
    return nil unless parsed

    Renderer.new(multiplicand: parsed[:multiplicand], multiplier: parsed[:multiplier], **options)
  end

  # Factory: crea più Renderer da stringhe separate da ; o \n
  def self.build_renderers(operations_string, **options)
    parse_multiple(operations_string).filter_map do |parsed|
      Renderer.new(multiplicand: parsed[:multiplicand], multiplier: parsed[:multiplier], **options)
    end
  end

  # Istanza: converte record DB in Renderer
  def to_renderer
    Renderer.new(**data.symbolize_keys)
  end
end
