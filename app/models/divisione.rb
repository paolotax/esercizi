# frozen_string_literal: true

require "bigdecimal"

# Modello per rappresentare una divisione in colonna (metodo italiano)
# Supporta divisioni con resto e calcolo passo-passo
# Supporta numeri decimali con virgola spostabile
#
# Layout divisione italiana:
#   dividendo | divisore
#   ----------|----------
#             | quoziente
#   resti...  |
#
class Divisione
  attr_reader :dividend, :divisor, :quotient, :remainder,
              :show_dividend_divisor, :show_toolbar, :show_solution, :show_steps,
              :title, :raw_dividend, :raw_divisor,
              :dividend_decimals, :divisor_decimals, :decimal_shift,
              :extra_zeros

  def initialize(dividend:, divisor:, **options)
    # Salva le stringhe originali con virgola
    @raw_dividend = normalize_number_string(dividend)
    @raw_divisor = normalize_number_string(divisor)

    # Conta i decimali originali
    @dividend_decimals = count_decimals(@raw_dividend)
    @divisor_decimals = count_decimals(@raw_divisor)

    # Calcola lo shift decimale (quante posizioni spostare la virgola)
    # Per rendere il divisore intero, dobbiamo spostare entrambi dello stesso numero di posizioni
    @decimal_shift = @divisor_decimals

    # Per il calcolo interno, convertiamo a interi spostando la virgola
    # Es: 12,5 : 2,5 diventa 125 : 25
    @dividend = to_integer_shifted(@raw_dividend, @decimal_shift)
    @divisor = to_integer_shifted(@raw_divisor, @decimal_shift)

    raise ArgumentError, "Il divisore non può essere zero" if @divisor.zero?

    @quotient = @dividend / @divisor
    @remainder = @dividend % @divisor

    # Numero di zeri extra per continuare la divisione (configurabile)
    @extra_zeros = options.fetch(:extra_zeros, 0)

    # Opzioni di visualizzazione
    @title = options[:title]
    @show_dividend_divisor = options.fetch(:show_dividend_divisor, true)
    @show_toolbar = options.fetch(:show_toolbar, true)
    @show_solution = options.fetch(:show_solution, false)
    @show_steps = options.fetch(:show_steps, false)
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

  # Converte un numero decimale in intero spostando la virgola
  # Es: "12.5" con shift=1 diventa 125
  # Es: "12.5" con shift=2 diventa 1250
  def to_integer_shifted(str, shift)
    decimals = count_decimals(str)
    # Rimuovi il punto
    digits_only = str.gsub(".", "")
    # Se lo shift è maggiore dei decimali esistenti, aggiungi zeri
    zeros_to_add = shift - decimals
    if zeros_to_add > 0
      digits_only += "0" * zeros_to_add
    end
    digits_only.to_i
  end

  # Verifica se l'operazione ha decimali
  def has_decimals?
    @dividend_decimals > 0 || @divisor_decimals > 0
  end

  # Posizione della virgola nel quoziente (da destra)
  # Dipende da quanti decimali ha il dividendo dopo lo shift + gli zeri extra
  def quotient_decimal_position
    # Se il dividendo originale ha più decimali del divisore, il quoziente avrà decimali
    extra_dividend_decimals = @dividend_decimals - @divisor_decimals
    # Aggiungi gli zeri extra che abbiamo aggiunto al dividendo
    base_decimals = extra_dividend_decimals > 0 ? extra_dividend_decimals : 0
    base_decimals + @extra_zeros
  end

  # Numero di cifre del dividendo
  def dividend_length
    @dividend.to_s.length
  end

  # Numero di cifre del divisore
  def divisor_length
    @divisor.to_s.length
  end

  # Numero di cifre del quoziente (include extra zeros)
  def quotient_length
    extended_quotient.length
  end

  # Cifre del dividendo come array (interno, senza virgola)
  def dividend_digits
    @dividend.to_s.chars
  end

  # Cifre del divisore come array (interno, senza virgola)
  def divisor_digits
    @divisor.to_s.chars
  end

  # Cifre del quoziente come array (include extra zeros)
  def quotient_digits
    extended_quotient.chars
  end

  # Quoziente esteso calcolato con gli zeri extra
  def extended_quotient
    return @extended_quotient if @extended_quotient

    extended_dividend = @dividend.to_s + ("0" * @extra_zeros)
    result = ""
    partial = 0

    extended_dividend.each_char do |digit|
      partial = partial * 10 + digit.to_i
      q_digit = partial / @divisor
      result += q_digit.to_s
      partial = partial - (q_digit * @divisor)
    end

    # Rimuovi zeri iniziali (ma lascia almeno una cifra)
    @extended_quotient = result.sub(/^0+(?=\d)/, "")
  end

  # Cifre originali del dividendo (con info posizione virgola)
  def raw_dividend_digits
    @raw_dividend.gsub(".", "").chars
  end

  # Cifre originali del divisore (con info posizione virgola)
  def raw_divisor_digits
    @raw_divisor.gsub(".", "").chars
  end

  # Calcola i passi della divisione in colonna
  # Restituisce un array di hash con:
  #   - partial_dividend: il dividendo parziale in quel passo
  #   - quotient_digit: la cifra del quoziente
  #   - product: il prodotto (divisore × cifra quoziente)
  #   - remainder: il resto parziale
  #   - bring_down: la cifra abbassata (se presente)
  #   - is_extra_zero: true se questa cifra è uno zero aggiunto
  def division_steps
    steps = []
    dividend_str = @dividend.to_s
    # Aggiungi gli zeri extra al dividendo per continuare la divisione
    extended_dividend = dividend_str + ("0" * @extra_zeros)
    partial_dividend = 0
    quotient_str = ""

    extended_dividend.each_char.with_index do |digit, idx|
      # Abbassa la cifra
      partial_dividend = partial_dividend * 10 + digit.to_i

      # Calcola la cifra del quoziente
      q_digit = partial_dividend / @divisor
      quotient_str += q_digit.to_s

      # Calcola il prodotto e il resto
      product = q_digit * @divisor
      remainder = partial_dividend - product

      # Determina la prossima cifra da abbassare
      next_idx = idx + 1
      bring_down = next_idx < extended_dividend.length ? extended_dividend[next_idx] : nil

      steps << {
        step_index: idx,
        partial_dividend: partial_dividend,
        quotient_digit: q_digit,
        product: product,
        remainder: remainder,
        bring_down: bring_down,
        is_extra_zero: idx >= dividend_str.length
      }

      partial_dividend = remainder
    end

    steps
  end

  # Numero massimo di righe per i calcoli intermedi
  # (ogni passo può generare fino a 2 righe: prodotto e resto)
  def max_calculation_rows
    dividend_length * 2
  end

  # Larghezza della colonna sinistra (dividendo e calcoli)
  def left_column_width
    # Il dividendo determina la larghezza base
    # Aggiungiamo 1 per eventuali resti che possono essere più larghi
    [ dividend_length, (@quotient * @divisor).to_s.length ].max + 1
  end

  # Larghezza della colonna destra (divisore e quoziente)
  def right_column_width
    [ divisor_length, quotient_length ].max
  end

  # Parsing di una stringa come "144 : 12" o "144/12" o "12,5 : 2,5"
  def self.parse(operation_string)
    return nil if operation_string.blank?

    # Supporta : / ÷ come operatori
    parts = operation_string.gsub(/\s+/, "").split(/[:\÷\/]/)

    return nil if parts.length < 2

    dividend = parts[0]
    divisor = parts[1]

    # Verifica che i numeri siano validi (possono avere virgola o punto)
    return nil unless dividend.match?(/^\d+([.,]\d+)?$/)
    return nil unless divisor.match?(/^\d+([.,]\d+)?$/)
    return nil if divisor.gsub(/[.,]/, "").to_i.zero?

    new(dividend: dividend, divisor: divisor)
  end

  # Parsing di più operazioni
  def self.parse_multiple(operations_string)
    return [] if operations_string.blank?

    operations_string
      .split(/[;\n]/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |op| parse(op) }
      .compact
  end

  # Verifica se la divisione ha resto
  def has_remainder?
    @remainder > 0
  end

  # Verifica se è una divisione esatta
  def exact?
    @remainder.zero?
  end

  # Stringa per display
  def to_s
    if has_remainder?
      "#{@dividend} : #{@divisor} = #{@quotient} resto #{@remainder}"
    else
      "#{@dividend} : #{@divisor} = #{@quotient}"
    end
  end

  # Parametri da passare al partial
  def to_partial_params
    { divisione: self }
  end

  # Genera la matrice per il partial unificato _quaderno_grid
  # La divisione italiana ha un layout particolare:
  # - Colonna sinistra: dividendo sopra, passi intermedi sotto
  # - Separatore verticale
  # - Colonna destra: divisore sopra, quoziente sotto
  def to_grid_matrix
    left_cols = left_column_width
    right_cols = right_column_width
    separator_col = 1  # Colonna separatore verticale
    total_cols = left_cols + separator_col + right_cols + 2 # +2 margini

    cell_size = "2.5em"
    steps = division_steps

    rows = []

    # Riga dividendo | divisore (con bordo sotto dividendo)
    rows << build_dividend_divisor_row(left_cols, right_cols, total_cols, cell_size)

    # Riga quoziente (sotto il divisore)
    rows << build_quotient_row(left_cols, right_cols, total_cols, cell_size)

    # Righe passi intermedi (prodotti, resti, abbassamenti)
    steps.each_with_index do |step, step_idx|
      # Riga prodotto (divisore × cifra quoziente)
      rows << build_product_row(step, step_idx, left_cols, right_cols, total_cols, cell_size)

      # Riga resto (con cifra abbassata se presente)
      next_step_has_bring_down = step[:bring_down].present?
      rows << build_remainder_row(step, step_idx, left_cols, right_cols, total_cols, cell_size, next_step_has_bring_down)
    end

    # Riga vuota sotto
    rows << { type: :empty, height: cell_size }

    # Riga toolbar
    rows << { type: :toolbar } if @show_toolbar

    {
      columns: total_cols,
      cell_size: cell_size,
      controller: "quaderno",
      title: @title,
      show_toolbar: @show_toolbar,
      separator_col: left_cols + 1,  # Posizione del separatore verticale
      remainder: has_remainder? ? @remainder : nil,
      rows: rows
    }
  end

  private

  def build_dividend_divisor_row(left_cols, right_cols, total_cols, cell_size)
    cells = []
    div_digits = raw_dividend_digits
    divisor_digs = raw_divisor_digits

    # Margine sinistro
    cells << { type: :empty }

    # Dividendo (allineato a destra nella colonna sinistra)
    padding_left = left_cols - div_digits.length
    padding_left.times { cells << { type: :empty } }

    div_digits.each_with_index do |digit, idx|
      pos_from_right = div_digits.length - 1 - idx
      show_comma = @dividend_decimals > 0 && pos_from_right == @dividend_decimals - @decimal_shift

      cell = {
        type: :digit,
        value: digit,
        target: "input",
        editable: true,
        row: 0,
        col: padding_left + idx,
        show_value: @show_dividend_divisor,
        classes: "text-gray-800 dark:text-gray-100",
        nav_direction: "ltr"
      }

      # Virgola spostabile nel dividendo
      if @dividend_decimals > 0 && pos_from_right == @dividend_decimals
        cell[:comma_shift] = {
          type: "dividend",
          position: idx,
          should_shift: @decimal_shift > 0
        }
      end

      cells << cell
    end

    # Separatore verticale (bordo spesso a sinistra)
    cells << { type: :empty }

    # Divisore (allineato a sinistra nella colonna destra)
    divisor_digs.each_with_index do |digit, idx|
      pos_from_right = divisor_digs.length - 1 - idx
      show_comma = @divisor_decimals > 0 && pos_from_right == @divisor_decimals

      cell = {
        type: :digit,
        value: digit,
        target: "input",
        editable: true,
        row: 0,
        col: left_cols + 1 + idx,
        show_value: @show_dividend_divisor,
        classes: "text-gray-800 dark:text-gray-100",
        nav_direction: "ltr"
      }

      # Virgola spostabile nel divisore
      if show_comma
        cell[:comma_shift] = {
          type: "divisor",
          position: idx,
          should_shift: @decimal_shift > 0
        }
      end

      cells << cell
    end

    # Padding destra divisore
    padding_right = right_cols - divisor_digs.length
    padding_right.times { cells << { type: :empty } }

    # Margine destro
    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells, separator_col: left_cols + 1 }
  end

  def build_quotient_row(left_cols, right_cols, total_cols, cell_size)
    cells = []
    quot_digits = quotient_digits
    decimal_pos = quotient_decimal_position

    # Margine sinistro + colonne vuote sinistra
    cells << { type: :empty }
    left_cols.times { cells << { type: :empty } }

    # Separatore
    cells << { type: :empty }

    # Quoziente (allineato a sinistra nella colonna destra)
    quot_digits.each_with_index do |digit, idx|
      pos_from_right = quot_digits.length - 1 - idx
      is_correct_comma_position = decimal_pos > 0 && pos_from_right == decimal_pos
      can_have_comma_spot = decimal_pos > 0 && pos_from_right > 0 && pos_from_right < quot_digits.length

      cell = {
        type: :digit,
        value: digit,
        target: "result",
        editable: true,
        row: 1,
        col: left_cols + 1 + idx,
        show_value: @show_solution,
        classes: "text-gray-800 dark:text-gray-100",
        nav_direction: "ltr"
      }

      if can_have_comma_spot
        cell[:comma_spot] = {
          correct: is_correct_comma_position,
          position: pos_from_right
        }
      end

      cells << cell
    end

    # Padding destra quoziente
    padding_right = right_cols - quot_digits.length
    padding_right.times { cells << { type: :empty } }

    # Margine destro
    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells, thick_border_top: true, separator_col: left_cols + 1 }
  end

  def build_product_row(step, step_idx, left_cols, right_cols, total_cols, cell_size)
    cells = []
    product_str = step[:product].to_s
    product_digits = product_str.chars

    # Posizione del prodotto: allineato sotto il dividendo parziale
    # Il prodotto va allineato a destra rispetto alla posizione corrente nel dividendo
    align_position = step[:step_index]

    # Margine sinistro
    cells << { type: :empty }

    # Celle vuote prima del prodotto
    padding = align_position - product_digits.length + 1
    padding = 0 if padding < 0
    padding.times { cells << { type: :empty } }

    # Segno meno
    cells << {
      type: :sign,
      value: "-",
      classes: "text-purple-600 dark:text-purple-400"
    }

    # Cifre del prodotto
    product_digits.each_with_index do |digit, idx|
      cells << {
        type: :digit,
        value: digit,
        target: "input",
        editable: true,
        row: 2 + step_idx * 2,
        col: padding + 1 + idx,
        show_value: @show_steps,
        classes: "text-gray-800 dark:text-gray-100",
        nav_direction: "ltr"
      }
    end

    # Celle vuote rimanenti a sinistra
    remaining_left = left_cols - padding - 1 - product_digits.length
    remaining_left.times { cells << { type: :empty } } if remaining_left > 0

    # Separatore
    cells << { type: :empty }

    # Colonne destra vuote
    right_cols.times { cells << { type: :empty } }

    # Margine destro
    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells, separator_col: left_cols + 1 }
  end

  def build_remainder_row(step, step_idx, left_cols, right_cols, total_cols, cell_size, has_bring_down)
    cells = []
    remainder_val = step[:remainder]
    bring_down = step[:bring_down]

    # Se c'è una cifra da abbassare, il resto si combina con essa
    if has_bring_down
      combined = remainder_val.to_s + bring_down.to_s
    else
      combined = remainder_val.to_s
    end
    combined_digits = combined.chars

    # Posizione: allineato sotto il prodotto
    align_position = step[:step_index] + (has_bring_down ? 1 : 0)

    # Margine sinistro
    cells << { type: :empty }

    # Celle vuote prima del resto
    padding = align_position - combined_digits.length + 1
    padding = 0 if padding < 0
    padding.times { cells << { type: :empty } }

    # Cifre del resto (+ cifra abbassata se presente)
    combined_digits.each_with_index do |digit, idx|
      is_bring_down = has_bring_down && idx == combined_digits.length - 1

      cells << {
        type: :digit,
        value: digit,
        target: is_bring_down ? "input" : "result",
        editable: true,
        row: 3 + step_idx * 2,
        col: padding + idx,
        show_value: @show_steps,
        classes: is_bring_down ? "text-blue-600 dark:text-blue-400" : "text-gray-800 dark:text-gray-100",
        nav_direction: "ltr"
      }
    end

    # Celle vuote rimanenti a sinistra
    remaining_left = left_cols - padding - combined_digits.length
    remaining_left.times { cells << { type: :empty } } if remaining_left > 0

    # Separatore
    cells << { type: :empty }

    # Colonne destra vuote
    right_cols.times { cells << { type: :empty } }

    # Margine destro
    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells, thick_border_top: true, separator_col: left_cols + 1 }
  end
end
