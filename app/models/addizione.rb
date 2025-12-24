# frozen_string_literal: true

class Addizione < ApplicationRecord
  include Questionable
  include AddizioneCalculation

  self.table_name = "addizioni"

  # Accessors per il campo JSON data
  store_accessor :data, :addends, :operator, :title,
                 :show_exercise, :show_addends, :show_solution,
                 :show_toolbar, :show_carry, :show_labels, :show_addend_indices

  # Reset dei calcoli quando cambiano i dati
  after_save :reset_calculations!

  # Parse: estrae addendi e operatore da stringa (es: "234 + 567")
  def self.parse(operation_string)
    return nil if operation_string.blank?

    parts = operation_string.gsub(/\s+/, "").split(/([+\-=])/)

    numbers = []
    operator = "+"

    parts.each do |part|
      if part.match?(/^\d+([.,]\d+)?$/)
        numbers << part.gsub(",", ".")
      elsif part.match?(/^[+\-]$/)
        operator = part
      end
    end

    return nil if numbers.empty?

    { addends: numbers, operator: operator }
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

  # Factory: crea un record DB da stringa operazione
  # Es: Addizione.from_string("12 + 13") oppure Addizione.from_string("12 + 13", title: "Esercizio 1")
  def self.from_string(operation_string, **options)
    parsed = parse(operation_string)
    return nil unless parsed

    create(addends: parsed[:addends], operator: parsed[:operator], **options)
  end

  # Factory: crea più record DB da stringhe separate da ; o \n
  def self.from_strings(operations_string, **options)
    parse_multiple(operations_string).filter_map do |parsed|
      create(addends: parsed[:addends], operator: parsed[:operator], **options)
    end
  end

  # Factory: crea un Renderer da stringa operazione
  def self.build_renderer(operation_string, **options)
    parsed = parse(operation_string)
    return nil unless parsed

    Renderer.new(addends: parsed[:addends], operator: parsed[:operator], **options)
  end

  # Factory: crea più Renderer da stringhe separate da ; o \n
  def self.build_renderers(operations_string, **options)
    parse_multiple(operations_string).filter_map do |parsed|
      Renderer.new(addends: parsed[:addends], operator: parsed[:operator], **options)
    end
  end

  # Istanza: converte record DB in Renderer
  def to_renderer
    Renderer.new(**data.symbolize_keys)
  end
end
