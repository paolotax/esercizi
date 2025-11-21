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

  # Dati per i prodotti parziali (una riga per ogni cifra del moltiplicatore)
  # Restituisce un array di hash con :digits, :carries, :num_inputs, :num_carries
  def partial_products_data
    return [] unless show_partial_products && multiplier_length > 1

    multiplier_digits.reverse.each_with_index.map do |digit, row_index|
      partial_product = multiplicand * digit
      partial_str = partial_product.to_s

      # Numero di input per questa riga = product_length - zeri_segnaposto
      num_inputs = product_length - row_index
      num_carries = num_inputs - 1

      # Calcola le cifre del prodotto parziale (allineate a destra)
      digits = partial_str.chars.map(&:to_i)
      # Padding a sinistra con nil per allineare a destra
      padded_digits = Array.new(num_inputs - digits.length, nil) + digits

      # Calcola i riporti
      carries = calculate_partial_carries(digit)
      # Padding a sinistra per allineare
      padded_carries = Array.new(num_carries - carries.length, nil) + carries.reverse

      {
        digits: padded_digits,
        carries: padded_carries,
        num_inputs: num_inputs,
        num_carries: num_carries,
        row_index: row_index
      }
    end
  end

  # Calcola i riporti per un prodotto parziale (moltiplicando × una cifra del moltiplicatore)
  def calculate_partial_carries(multiplier_digit)
    multiplicand_reversed = multiplicand.to_s.chars.reverse.map(&:to_i)
    carry = 0
    carries = []

    multiplicand_reversed.each do |d|
      product = d * multiplier_digit + carry
      carry = product / 10
      carries << (carry > 0 ? carry : nil)
    end

    # Rimuovi l'ultimo riporto (va oltre il numero di cifre)
    carries.pop
    carries
  end

  # Riporti per il risultato finale
  def result_carries
    if show_partial_products && multiplier_length > 1
      # Riporti dalla somma dei prodotti parziali
      calculate_sum_carries
    else
      # Riporti dalla moltiplicazione diretta
      calculate_direct_multiplication_carries
    end
  end

  # Calcola i riporti dalla moltiplicazione diretta (senza prodotti parziali)
  def calculate_direct_multiplication_carries
    multiplicand_reversed = multiplicand.to_s.chars.reverse.map(&:to_i)
    carry = 0
    carries = []

    multiplicand_reversed.each_with_index do |d, i|
      partial_result = d * multiplier + carry
      carry = partial_result / 10
      # Il riporto va sopra la cifra successiva (più a sinistra)
      carries << (carry > 0 ? carry : nil) if i < multiplicand_reversed.length - 1
    end

    # Padding a sinistra per avere product_length + 1 elementi
    # I riporti sono allineati con le cifre del risultato (shiftati di 1 a sinistra)
    result = Array.new(product_length + 1 - carries.length - 1, nil) + carries.reverse + [nil]
    result
  end

  # Calcola i riporti dalla somma dei prodotti parziali
  def calculate_sum_carries
    multiplier_reversed = multiplier.to_s.chars.reverse.map(&:to_i)
    carries = []
    carry = 0

    product_length.times do |col|
      sum = carry

      # Somma le cifre dei prodotti parziali per questa colonna
      multiplier_reversed.each_with_index do |digit, row_index|
        partial = multiplicand * digit
        partial_str = partial.to_s.reverse
        col_in_partial = col - row_index

        if col_in_partial >= 0 && col_in_partial < partial_str.length
          sum += partial_str[col_in_partial].to_i
        end
      end

      carry = sum / 10
      carries << (carry > 0 ? carry : nil) if col < product_length - 1
    end

    # Padding per avere product_length elementi (allineato con il risultato)
    # I riporti vanno sopra le cifre dalla seconda posizione in poi
    result = Array.new(product_length - carries.length - 1, nil) + carries.reverse + [nil]
    result
  end

  # Cifre del risultato con correct answer
  def result_digits_array
    product.to_s.chars.map(&:to_i)
  end

  # Parametri da passare al partial
  def to_partial_params
    { moltiplicazione: self }
  end
end
