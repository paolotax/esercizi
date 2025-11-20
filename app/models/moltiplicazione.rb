# frozen_string_literal: true

# Modello per rappresentare una moltiplicazione in colonna
class Moltiplicazione
  attr_reader :multiplicand, :multiplier, :show_multiplicand_multiplier, :show_toolbar,
              :show_partial_products, :editable, :show_exercise

  def initialize(multiplicand:, multiplier:, **options)
    @multiplicand = multiplicand.to_i
    @multiplier = multiplier.to_i
    @show_multiplicand_multiplier = options.fetch(:show_multiplicand_multiplier, true)
    @show_toolbar = options.fetch(:show_toolbar, true)
    @show_partial_products = options.fetch(:show_partial_products, true)
    @editable = options.fetch(:editable, true)
    @show_exercise = options.fetch(:show_exercise, false)
  end

  # Cifre del moltiplicando (da destra a sinistra)
  def multiplicand_digits
    @multiplicand.to_s.chars.map(&:to_i)
  end

  # Cifre del moltiplicatore (da destra a sinistra)
  def multiplier_digits
    @multiplier.to_s.chars.map(&:to_i)
  end

  # Numero di cifre
  def multiplicand_length
    @multiplicand.to_s.length
  end

  def multiplier_length
    @multiplier.to_s.length
  end

  # Prodotto finale
  def product
    @multiplicand * @multiplier
  end

  # Prodotti parziali (uno per ogni cifra del moltiplicatore)
  def partial_products
    multiplier_digits.reverse.map.with_index do |digit, index|
      (@multiplicand * digit) * (10**index)
    end
  end

  # Cifre del prodotto finale
  def product_digits
    product.to_s.chars.map(&:to_i)
  end

  def product_length
    product.to_s.length
  end

  # Parsing di una stringa come "123x45" o "123x45:show_toolbar=false"
  def self.parse(line)
    parts = line.strip.split(":", 2)
    numbers_str = parts[0]
    params_str = parts[1]

    return nil if numbers_str.blank?

    # Parse moltiplicazione (123x45 o 123*45)
    match = numbers_str.match(/^(\d+)\s*[x*×]\s*(\d+)$/i)
    return nil unless match

    multiplicand = match[1].to_i
    multiplier = match[2].to_i

    options = { multiplicand: multiplicand, multiplier: multiplier }

    # Parse parametri opzionali
    if params_str.present?
      params_str.split(",").each do |param|
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
        when "show_multiplicand_multiplier", "show_numbers"
          options[:show_multiplicand_multiplier] = parsed_value
        when "show_toolbar", "toolbar"
          options[:show_toolbar] = parsed_value
        when "show_partial_products", "show_partials"
          options[:show_partial_products] = parsed_value
        when "editable"
          options[:editable] = parsed_value
        when "show_exercise"
          options[:show_exercise] = parsed_value
        end
      end
    end

    new(**options)
  end

  # Parsing di più moltiplicazioni separate da spazi/newline
  def self.parse_multiple(multiplications_string)
    return [] if multiplications_string.blank?

    multiplications_string
      .split(/[\s\n]+/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |line| parse(line) }
      .compact
  end

  # Parametri da passare al partial
  def to_partial_params
    { moltiplicazione: self }
  end
end
