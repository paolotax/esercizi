# frozen_string_literal: true

class Divisione < ApplicationRecord
  include Questionable

  self.table_name = "divisioni"

  # Parse: estrae dividendo e divisore da stringa (es: "144:12" o "14,4:1,2")
  def self.parse(operation_string)
    return nil if operation_string.blank?

    # Supporta : / ÷ come operatori
    parts = operation_string.gsub(/\s+/, "").split(/[:÷\/]/)

    return nil if parts.length < 2

    dividend = parts[0].gsub(",", ".")
    divisor = parts[1].gsub(",", ".")

    # Verifica che i numeri siano validi
    return nil unless dividend.match?(/^\d+(\.\d+)?$/)
    return nil unless divisor.match?(/^\d+(\.\d+)?$/)
    return nil if divisor.gsub(".", "").to_i.zero?

    { dividend: dividend, divisor: divisor }
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

    Renderer.new(dividend: parsed[:dividend], divisor: parsed[:divisor], **options)
  end

  # Factory: crea più Renderer da stringhe separate da ; o \n
  def self.build_renderers(operations_string, **options)
    parse_multiple(operations_string).filter_map do |parsed|
      Renderer.new(dividend: parsed[:dividend], divisor: parsed[:divisor], **options)
    end
  end

  # Istanza: converte record DB in Renderer
  def to_renderer
    Renderer.new(**data.symbolize_keys)
  end
end
