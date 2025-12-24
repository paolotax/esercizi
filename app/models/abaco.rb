# frozen_string_literal: true

class Abaco < ApplicationRecord
  include Questionable

  self.table_name = "abachi"

  # Parse: estrae configurazione abaco da stringa (es: "columns=3,h=3,da=8,u=6")
  def self.parse(config_string)
    return nil if config_string.blank?

    options = {}

    config_string.strip.split(",").each do |param|
      key, value = param.split("=", 2).map(&:strip)
      next if key.blank?

      parsed_value = case value&.downcase
      when "nil", "null", ""
        nil
      when "true"
        true
      when "false"
        false
      else
        value.to_i
      end

      case key.downcase
      when "columns"
        options[:columns] = parsed_value
      when "k", "migliaia"
        options[:k] = parsed_value
      when "h", "centinaia"
        options[:h] = parsed_value
      when "da", "decine"
        options[:da] = parsed_value
      when "u", "unita"
        options[:u] = parsed_value
      when "editable"
        options[:editable] = parsed_value
      when "show_value"
        options[:show_value] = parsed_value
      when "correct_value"
        options[:correct_value] = parsed_value
      when "mode"
        options[:mode] = value&.to_sym
      when "max_per_column"
        options[:max_per_column] = parsed_value
      end
    end

    options
  end

  # Parse multiple: estrae da stringhe separate da ; o \n
  def self.parse_multiple(configs_string)
    return [] if configs_string.blank?

    configs_string
      .split(/[;\n]/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |config| parse(config) }
      .compact
  end

  # Factory: crea un Renderer da stringa configurazione
  def self.build_renderer(config_string, **options)
    parsed = parse(config_string)
    return nil unless parsed

    Renderer.new(**parsed.merge(options))
  end

  # Factory: crea più Renderer da stringhe separate da ; o \n
  def self.build_renderers(configs_string, **options)
    parse_multiple(configs_string).filter_map do |parsed|
      Renderer.new(**parsed.merge(options))
    end
  end

  # Istanza: converte record DB in Renderer
  def to_renderer
    Renderer.new(**data.symbolize_keys)
  end
end
