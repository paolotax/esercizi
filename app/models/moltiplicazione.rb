# frozen_string_literal: true

require "bigdecimal"

# Modello per rappresentare una moltiplicazione in colonna
# Supporta sia numeri interi che decimali (con virgola)
class Moltiplicazione
  attr_reader :multiplicand, :multiplier, :show_multiplicand_multiplier, :show_toolbar,
              :show_partial_products, :editable, :show_exercise, :show_solution, :show_labels,
              :decimal_places, :multiplicand_decimals, :multiplier_decimals,
              :max_integer_digits, :raw_multiplicand, :raw_multiplier

  def initialize(multiplicand:, multiplier:, **options)
    @raw_multiplicand = normalize_number_string(multiplicand)
    @raw_multiplier = normalize_number_string(multiplier)
    @multiplicand_decimals = count_decimals(@raw_multiplicand)
    @multiplier_decimals = count_decimals(@raw_multiplier)
    @decimal_places = @multiplicand_decimals + @multiplier_decimals
    @multiplicand = parse_to_number(@raw_multiplicand)
    @multiplier = parse_to_number(@raw_multiplier)
    @max_integer_digits = calculate_max_integer_digits

    @show_multiplicand_multiplier = options.fetch(:show_multiplicand_multiplier, true)
    @show_toolbar = options.fetch(:show_toolbar, true)
    @show_partial_products = options.fetch(:show_partial_products, false)
    @editable = options.fetch(:editable, true)
    @show_exercise = options.fetch(:show_exercise, false)
    @show_solution = options.fetch(:show_solution, false)
    @show_labels = options.fetch(:show_labels, false)
  end

  # Normalizza una stringa numerica: accetta virgola o punto come separatore
  def normalize_number_string(value)
    return value.to_s if value.is_a?(Integer)
    str = value.to_s.strip
    str.gsub(",", ".")
  end

  # Conta le cifre decimali di una stringa numerica
  def count_decimals(str)
    if str.include?(".")
      str.split(".").last.length
    else
      0
    end
  end

  # Converte stringa in numero (Integer o BigDecimal per precisione)
  def parse_to_number(str)
    str.include?(".") ? BigDecimal(str) : str.to_i
  end

  # Calcola il numero massimo di cifre intere nel risultato
  def calculate_max_integer_digits
    product_value = @multiplicand * @multiplier
    product_value.abs.to_i.to_s.length
  end

  # Verifica se l'operazione ha decimali
  def has_decimals?
    @decimal_places > 0
  end

  # Numero massimo di cifre per il quaderno (include decimali)
  def max_digits
    @max_integer_digits + @decimal_places
  end

  # Numero totale di colonne per le cifre (senza colonna virgola separata)
  def total_digit_columns
    max_digits
  end

  # Posizione della virgola nel risultato (da destra, 0-indexed)
  # Se decimal_places = 2, virgola va dopo la seconda cifra da destra
  def comma_position_from_right
    @decimal_places
  end

  # Etichette per il quaderno (include decimali)
  def quaderno_labels
    labels = []

    # Multipli (parte intera)
    labels << "M" if @max_integer_digits >= 7
    labels << "hk" if @max_integer_digits >= 6
    labels << "dak" if @max_integer_digits >= 5
    labels << "uk" if @max_integer_digits >= 4
    labels << "h" if @max_integer_digits >= 3
    labels << "da" if @max_integer_digits >= 2
    labels << "u"

    while labels.length < @max_integer_digits
      labels.unshift("")
    end

    # Sottomultipli (parte decimale)
    if has_decimals?
      labels << "d" if @decimal_places >= 1
      labels << "c" if @decimal_places >= 2
      labels << "m" if @decimal_places >= 3
      # Per più di 3 decimali
      (@decimal_places - 3).times { labels << "" } if @decimal_places > 3
    end

    labels
  end

  # Colori per le etichette del quaderno
  def quaderno_label_colors
    colors = []

    colors << "text-purple-600 dark:text-purple-400" if @max_integer_digits >= 7
    colors << "text-orange-600 dark:text-orange-400" if @max_integer_digits >= 6
    colors << "text-yellow-600 dark:text-yellow-400" if @max_integer_digits >= 5
    colors << "text-pink-600 dark:text-pink-400" if @max_integer_digits >= 4
    colors << "text-green-600 dark:text-green-400" if @max_integer_digits >= 3
    colors << "text-red-500 dark:text-red-400" if @max_integer_digits >= 2
    colors << "text-blue-600 dark:text-blue-400"

    while colors.length < @max_integer_digits
      colors.unshift("text-gray-400 dark:text-gray-500")
    end

    if has_decimals?
      colors << "text-cyan-600 dark:text-cyan-400" if @decimal_places >= 1
      colors << "text-teal-600 dark:text-teal-400" if @decimal_places >= 2
      colors << "text-emerald-600 dark:text-emerald-400" if @decimal_places >= 3
      (@decimal_places - 3).times { colors << "text-gray-400 dark:text-gray-500" } if @decimal_places > 3
    end

    colors
  end

  # Cifre del moltiplicando per il quaderno (senza virgola, allineate a destra)
  def quaderno_multiplicand_digits
    format_number_for_grid(@raw_multiplicand)
  end

  # Cifre del moltiplicatore per il quaderno (senza virgola, allineate a destra)
  def quaderno_multiplier_digits
    format_number_for_grid(@raw_multiplier)
  end

  # Cifre del risultato per il quaderno
  def quaderno_result_digits
    if has_decimals?
      result_str = format("%.#{@decimal_places}f", product)
      format_number_for_grid(result_str)
    else
      result_str = product.to_s
      padding = max_digits - result_str.length
      ([""] * padding) + result_str.chars
    end
  end

  # Formatta un numero per la griglia (allineato a destra, senza virgola)
  # Restituisce solo le cifre, la virgola sarà renderizzata separatamente
  def format_number_for_grid(raw_str)
    # Rimuovi il punto decimale e allinea a destra
    digits_only = raw_str.gsub(".", "")
    total_digits = max_digits
    padding = total_digits - digits_only.length
    ([""] * padding) + digits_only.chars
  end

  # Posizione della virgola per un numero specifico (da destra, 0-indexed)
  # Restituisce nil se non ha decimali
  def comma_position_for_number(raw_str)
    return nil unless raw_str.include?(".")
    raw_str.split(".").last.length
  end

  # Prodotto finale
  def product
    @multiplicand * @multiplier
  end

  # Lunghezza delle cifre (senza virgola)
  def multiplicand_length
    @raw_multiplicand.gsub(".", "").length
  end

  def multiplier_length
    @raw_multiplier.gsub(".", "").length
  end

  def product_length
    if has_decimals?
      format("%.#{@decimal_places}f", product).gsub(".", "").length
    else
      product.to_s.length
    end
  end

  # Cifre del moltiplicando come array di interi (per calcoli interni)
  def multiplicand_digits
    @raw_multiplicand.gsub(".", "").chars.map(&:to_i)
  end

  # Cifre del moltiplicatore come array di interi (per calcoli interni)
  def multiplier_digits
    @raw_multiplier.gsub(".", "").chars.map(&:to_i)
  end

  # Dati per i prodotti parziali nel formato quaderno
  def quaderno_partial_products
    return [] unless multiplier_length > 1

    mult_digits = multiplier_digits.reverse
    mult_digits.each_with_index.map do |digit, row_index|
      # Moltiplicando senza virgola × cifra del moltiplicatore
      multiplicand_int = @raw_multiplicand.gsub(".", "").to_i
      partial_product = multiplicand_int * digit
      partial_str = partial_product.to_s

      zeros = row_index
      digits = partial_str.chars
      cols_for_digits = max_digits - zeros
      padding = cols_for_digits - digits.length
      padded_digits = ([""] * padding) + digits

      {
        digits: padded_digits,
        zeros: zeros,
        row_index: row_index
      }
    end
  end

  # Riporti per la somma dei prodotti parziali
  def quaderno_sum_carries
    return [] unless multiplier_length > 1

    carries = Array.new(max_digits, "")
    carry = 0

    max_digits.times do |col_from_right|
      col_idx = max_digits - 1 - col_from_right
      sum = carry

      multiplier_digits.reverse.each_with_index do |digit, row_index|
        next if col_from_right < row_index

        multiplicand_int = @raw_multiplicand.gsub(".", "").to_i
        partial = multiplicand_int * digit
        partial_str = partial.to_s.reverse
        col_in_partial = col_from_right - row_index

        if col_in_partial >= 0 && col_in_partial < partial_str.length
          sum += partial_str[col_in_partial].to_i
        end
      end

      carry = sum / 10
      if carry > 0 && col_idx > 0
        carries[col_idx - 1] = carry.to_s
      end
    end

    carries
  end

  # Riporti per il risultato finale
  def result_carries
    if multiplier_length > 1
      calculate_sum_carries
    else
      calculate_direct_multiplication_carries
    end
  end

  # Calcola i riporti dalla moltiplicazione diretta
  def calculate_direct_multiplication_carries
    multiplicand_int = @raw_multiplicand.gsub(".", "").to_i
    multiplier_int = @raw_multiplier.gsub(".", "").to_i
    multiplicand_reversed = multiplicand_int.to_s.chars.reverse.map(&:to_i)
    num_carries = product_length - 1
    carries = Array.new(num_carries, nil)
    carry = 0

    multiplicand_reversed.each_with_index do |d, i|
      partial_result = d * multiplier_int + carry
      carry = partial_result / 10
      if carry > 0 && i < multiplicand_reversed.length - 1
        target_index = num_carries - 1 - i
        carries[target_index] = carry if target_index >= 0
      end
    end

    carries
  end

  # Calcola i riporti dalla somma dei prodotti parziali
  def calculate_sum_carries
    multiplier_reversed = multiplier_digits.reverse
    num_carries = product_length - 1
    carries = Array.new(num_carries, nil)
    carry = 0

    product_length.times do |col|
      sum = carry

      multiplier_reversed.each_with_index do |digit, row_index|
        multiplicand_int = @raw_multiplicand.gsub(".", "").to_i
        partial = multiplicand_int * digit
        partial_str = partial.to_s.reverse
        col_in_partial = col - row_index

        if col_in_partial >= 0 && col_in_partial < partial_str.length
          sum += partial_str[col_in_partial].to_i
        end
      end

      carry = sum / 10
      if carry > 0 && col < product_length - 1
        target_index = num_carries - 1 - col
        carries[target_index] = carry if target_index >= 0
      end
    end

    carries
  end

  # Parsing di una stringa come "123x45" o "12,3x4,5"
  def self.parse(line)
    parts = line.strip.split(":", 2)
    numbers_str = parts[0]
    params_str = parts[1]

    return nil if numbers_str.blank?

    # Parse moltiplicazione (supporta decimali)
    match = numbers_str.match(/^(\d+([.,]\d+)?)\s*[x*×]\s*(\d+([.,]\d+)?)$/i)
    return nil unless match

    multiplicand = match[1]
    multiplier = match[3]

    options = { multiplicand: multiplicand, multiplier: multiplier }

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

  # Parsing di più moltiplicazioni
  def self.parse_multiple(multiplications_string)
    return [] if multiplications_string.blank?

    multiplications_string
      .split(/[\s\n]+/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |line| parse(line) }
      .compact
  end

  # Dati per i prodotti parziali (compatibilità)
  def partial_products_data
    return [] unless multiplier_length > 1

    multiplier_digits.reverse.each_with_index.map do |digit, row_index|
      multiplicand_int = @raw_multiplicand.gsub(".", "").to_i
      partial_product = multiplicand_int * digit
      partial_str = partial_product.to_s

      num_inputs = product_length - row_index
      num_carries = num_inputs - 1

      digits = partial_str.chars.map(&:to_i)
      padded_digits = Array.new(num_inputs - digits.length, nil) + digits

      carries = calculate_partial_carries(digit)
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

  # Calcola i riporti per un prodotto parziale
  def calculate_partial_carries(multiplier_digit)
    multiplicand_int = @raw_multiplicand.gsub(".", "").to_i
    multiplicand_reversed = multiplicand_int.to_s.chars.reverse.map(&:to_i)
    carry = 0
    carries = []

    multiplicand_reversed.each do |d|
      product_val = d * multiplier_digit + carry
      carry = product_val / 10
      carries << (carry > 0 ? carry : nil)
    end

    carries.pop
    carries
  end

  # Cifre del risultato come array
  def result_digits_array
    if has_decimals?
      format("%.#{@decimal_places}f", product).gsub(".", "").chars.map(&:to_i)
    else
      product.to_s.chars.map(&:to_i)
    end
  end

  # Parametri da passare al partial
  def to_partial_params
    { moltiplicazione: self }
  end
end
