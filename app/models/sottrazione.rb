# frozen_string_literal: true

# Modello per rappresentare una sottrazione in colonna
class Sottrazione
  attr_reader :minuend, :subtrahend, :result, :max_digits,
              :title, :show_exercise, :show_minuend_subtrahend, :show_solution, :show_toolbar, :show_borrow

  def initialize(minuend:, subtrahend:, **options)
    @minuend = minuend
    @subtrahend = subtrahend
    @result = calculate_result
    @max_digits = [ @minuend, @subtrahend, @result ].compact.max.to_s.length

    # Opzioni di visualizzazione
    @title = options[:title]
    @show_exercise = options.fetch(:show_exercise, true)
    @show_minuend_subtrahend = options.fetch(:show_minuend_subtrahend, false)
    @show_solution = options.fetch(:show_solution, false)
    @show_toolbar = options.fetch(:show_toolbar, false)
    @show_borrow = options.fetch(:show_borrow, true)
  end

  # Parsing di una stringa come "487 - 258"
  def self.parse(operation_string)
    return nil if operation_string.blank?

    # Rimuovi spazi e split per operatore meno
    parts = operation_string.gsub(/\s+/, "").split(/[-=]/)

    # Estrai i due numeri
    numbers = parts.map { |p| p.to_i if p.match?(/^\d+$/) }.compact

    return nil if numbers.length < 2

    new(minuend: numbers[0], subtrahend: numbers[1])
  end

  # Parsing di più operazioni separate da virgola, punto e virgola o newline
  def self.parse_multiple(operations_string)
    return [] if operations_string.blank?

    operations_string
      .split(/[,;\n]/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |op| parse(op) }
      .compact
  end

  # Calcola il risultato della sottrazione
  def calculate_result
    @minuend - @subtrahend
  end

  # Calcola i prestiti per ogni colonna (da destra a sinistra)
  def borrows
    borrows_array = Array.new(@max_digits, "")
    crossed_out_array = Array.new(@max_digits, false)
    borrowed_minuend = minuend_digits.map { |d| d.present? ? d.to_i : 0 }

    (@max_digits - 1).downto(0) do |col_idx|
      minuend_digit = borrowed_minuend[col_idx]
      subtrahend_digit = subtrahend_digits[col_idx].present? ? subtrahend_digits[col_idx].to_i : 0

      # Se minuendo < sottraendo, serve un prestito
      if minuend_digit < subtrahend_digit && col_idx > 0
        # Prendi in prestito dalla colonna precedente (a sinistra)
        borrowed_minuend[col_idx] += 10
        borrowed_minuend[col_idx - 1] -= 1
        # Marca la cifra che presta come barrata
        crossed_out_array[col_idx - 1] = true
        # Sopra la cifra che presta, scrivo il nuovo valore
        borrows_array[col_idx - 1] = borrowed_minuend[col_idx - 1].to_s
      end
    end

    borrows_array
  end

  # Indica quali cifre del minuendo sono state barrate (hanno prestato)
  def crossed_out
    crossed_out_array = Array.new(@max_digits, false)
    borrowed_minuend = minuend_digits.map { |d| d.present? ? d.to_i : 0 }

    (@max_digits - 1).downto(0) do |col_idx|
      minuend_digit = borrowed_minuend[col_idx]
      subtrahend_digit = subtrahend_digits[col_idx].present? ? subtrahend_digits[col_idx].to_i : 0

      if minuend_digit < subtrahend_digit && col_idx > 0
        borrowed_minuend[col_idx] += 10
        borrowed_minuend[col_idx - 1] -= 1
        crossed_out_array[col_idx - 1] = true
      end
    end

    crossed_out_array
  end

  # Converti minuendo in array di cifre (da sinistra a destra)
  def minuend_digits
    num_str = @minuend.to_s
    padding = @max_digits - num_str.length
    ([ "" ] * padding) + num_str.chars
  end

  # Converti sottraendo in array di cifre (da sinistra a destra)
  def subtrahend_digits
    num_str = @subtrahend.to_s
    padding = @max_digits - num_str.length
    ([ "" ] * padding) + num_str.chars
  end

  # Array di cifre del risultato
  def result_digits
    result_str = @result.to_s
    result_padding = @max_digits - result_str.length
    ([ "" ] * result_padding) + result_str.chars
  end

  # Etichette delle colonne (da sinistra a destra: più significativo a meno significativo)
  def column_labels
    labels = []

    labels << "M" if @max_digits >= 7    # Milioni
    labels << "hk" if @max_digits >= 6   # Centinaia di migliaia
    labels << "dak" if @max_digits >= 5  # Decine di migliaia
    labels << "uk" if @max_digits >= 4   # Unità di migliaia
    labels << "h" if @max_digits >= 3    # Centinaia
    labels << "da" if @max_digits >= 2   # Decine
    labels << "u"                         # Unità (sempre presente)

    # Padding per avere sempre max_digits etichette
    while labels.length < @max_digits
      labels.unshift("")
    end

    labels
  end

  # Colori per le etichette delle colonne
  def column_colors
    colors = []

    colors << "text-purple-600" if @max_digits >= 7
    colors << "text-orange-600" if @max_digits >= 6
    colors << "text-yellow-600" if @max_digits >= 5
    colors << "text-pink-600" if @max_digits >= 4
    colors << "text-green-600" if @max_digits >= 3
    colors << "text-red-500" if @max_digits >= 2
    colors << "text-blue-600"

    while colors.length < @max_digits
      colors.unshift("text-gray-400")
    end

    colors
  end

  # Stile CSS per il grid
  def grid_style
    "display: grid; grid-template-columns: repeat(#{@max_digits}, 4rem); gap: 0;"
  end

  # Parametri da passare al partial - semplicemente l'oggetto stesso
  def to_partial_params
    { sottrazione: self }
  end

  # Stringa per display (es: "487 - 258")
  def to_s
    "#{@minuend} - #{@subtrahend}"
  end
end
