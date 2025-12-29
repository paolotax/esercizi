# frozen_string_literal: true

module Parseable
  extend ActiveSupport::Concern

  # Registry dei tipi
  mattr_accessor :registered_types, default: []

  included do
    Parseable.registered_types << self unless Parseable.registered_types.include?(self)
  end

  # Metodo di modulo per bulk creation
  # Ritorna { created: [questions], count: N } oppure { error: "message" }
  def self.create_all_from_text(text, esercizio:, options: {})
    return { created: [], count: 0 } if text.blank?

    lines = text.split(/[;\n,]/).map(&:strip).reject(&:blank?)
    created = []

    lines.each do |line|
      klass = registered_types.find { |k| line.gsub(/\s+/, "").match?(k.operator_regex) }
      next unless klass

      parsed = klass.parse(line)
      next unless parsed

      # Normalizza opzioni generiche in specifiche per questo tipo
      specific_options = klass.normalize_options(options)
      questionable = klass.create!(data: parsed.merge(specific_options))

      question = esercizio.questions.create!(
        questionable: questionable,
        position: esercizio.questions.count,
        account: Current.account,
        creator: Current.user
      )
      created << question
    end

    { created: created, count: created.size }
  end

  class_methods do
    # DSL: parseable operator: /[+]/, fields: [:addends]
    def parseable(operator:, fields:)
      @operator_regex = operator
      @field_names = fields
    end

    attr_reader :operator_regex, :field_names

    # Override nei model per validazioni custom
    def valid_operation?(parsed)
      true
    end

    # Override in Addizione per gestire N operandi
    def parse_result(parts)
      field_names.zip(parts).to_h
    end

    # Parse singola operazione
    def parse(operation_string)
      return nil if operation_string.blank?

      cleaned = operation_string.gsub(/\s+/, "")
      return nil unless cleaned.match?(operator_regex)

      parts = cleaned.split(operator_regex).map(&:strip).reject(&:blank?)
      return nil if parts.empty?
      return nil unless parts.all? { |p| valid_number?(p) }

      parsed = parse_result(parts.map { |p| p.gsub(",", ".") })
      return nil unless valid_operation?(parsed)

      parsed
    end

    # Parse multiple da testo
    def parse_multiple(text)
      return [] if text.blank?

      text.split(/[;\n,]/)
          .map(&:strip)
          .reject(&:blank?)
          .filter_map { |line| parse(line) }
    end

    # --- Factory: Renderer (oggetti in memoria) ---

    def build_renderer(operation_string, **options)
      parsed = parse(operation_string)
      return nil unless parsed

      self::Renderer.new(**parsed, **options)
    end

    def build_renderers(operations_string, **options)
      parse_multiple(operations_string).map do |parsed|
        self::Renderer.new(**parsed, **options)
      end
    end

    # --- Factory: DB Records ---

    def from_string(operation_string, **options)
      parsed = parse(operation_string)
      return nil unless parsed

      create(**parsed, **options)
    end

    def from_strings(operations_string, **options)
      parse_multiple(operations_string).map do |parsed|
        create(**parsed, **options)
      end
    end

    private

    def valid_number?(str)
      str.match?(/^\d+([.,]\d+)?$/)
    end
  end

  # Istanza: converte record DB in Renderer
  def to_renderer
    Renderer.new(**data.symbolize_keys)
  end
end
