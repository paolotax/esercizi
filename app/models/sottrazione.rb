# frozen_string_literal: true

class Sottrazione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Sottrazione::Calculation

  self.table_name = "sottrazioni"

  # Accessors per il campo JSON data
  store_accessor :data, :minuend, :subtrahend, :title,
                 :show_exercise, :show_minuend_subtrahend, :show_solution,
                 :show_toolbar, :show_borrow, :show_labels

  # Reset dei calcoli quando cambiano i dati
  after_save :reset_calculations!

  # Parse: estrae minuendo e sottraendo da stringa (es: "500 - 234")
  def self.parse(operation_string)
    return nil if operation_string.blank?

    parts = operation_string.gsub(/\s+/, "").split(/[-=]/)
    numbers = parts.map { |p| p.gsub(",", ".") if p.match?(/^\d+([.,]\d+)?$/) }.compact

    return nil if numbers.length < 2

    { minuend: numbers[0], subtrahend: numbers[1] }
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

  # Calcola risultato da hash parsed (per validazione)
  def self.calculate_result(parsed)
    minuend = parsed[:minuend].include?(".") ? BigDecimal(parsed[:minuend]) : parsed[:minuend].to_i
    subtrahend = parsed[:subtrahend].include?(".") ? BigDecimal(parsed[:subtrahend]) : parsed[:subtrahend].to_i
    minuend - subtrahend
  end

  # Factory: crea un record DB da stringa operazione
  # Es: Sottrazione.from_string("500 - 234") oppure Sottrazione.from_string("500 - 234", title: "Esercizio 1")
  # Ritorna nil se il risultato sarebbe negativo
  def self.from_string(operation_string, **options)
    parsed = parse(operation_string)
    return nil unless parsed
    return nil if calculate_result(parsed).negative?

    create(minuend: parsed[:minuend], subtrahend: parsed[:subtrahend], **options)
  end

  # Factory: crea più record DB da stringhe separate da ; o \n
  # Ignora sottrazioni con risultato negativo
  def self.from_strings(operations_string, **options)
    parse_multiple(operations_string).filter_map do |parsed|
      next if calculate_result(parsed).negative?
      create(minuend: parsed[:minuend], subtrahend: parsed[:subtrahend], **options)
    end
  end

  # Factory: crea un Renderer da stringa operazione
  # Ritorna nil se il risultato sarebbe negativo
  def self.build_renderer(operation_string, **options)
    parsed = parse(operation_string)
    return nil unless parsed
    return nil if calculate_result(parsed).negative?

    Renderer.new(minuend: parsed[:minuend], subtrahend: parsed[:subtrahend], **options)
  end

  # Factory: crea più Renderer da stringhe separate da ; o \n
  # Ignora sottrazioni con risultato negativo
  def self.build_renderers(operations_string, **options)
    parse_multiple(operations_string).filter_map do |parsed|
      next if calculate_result(parsed).negative?
      Renderer.new(minuend: parsed[:minuend], subtrahend: parsed[:subtrahend], **options)
    end
  end

  # Istanza: converte record DB in Renderer
  def to_renderer
    Renderer.new(**data.symbolize_keys)
  end
end
