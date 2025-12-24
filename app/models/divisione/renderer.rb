# frozen_string_literal: true

require "bigdecimal"

class Divisione
  # Renderer per rappresentare una divisione in colonna (metodo italiano)
  # Supporta divisioni con resto e calcolo passo-passo
  # Supporta numeri decimali con virgola spostabile
  #
  # Layout divisione italiana:
  #   dividendo | divisore
  #   ----------|----------
  #             | quoziente
  #   resti...  |
  #
  class Renderer
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

    # Filtra gli step come nel vecchio partial:
    # - Salta il primo step se q=0 (non c'è ancora niente da mostrare)
    display_steps = steps.reject.with_index { |s, i| i == 0 && s[:quotient_digit] == 0 }

    rows = []

    # Riga vuota sopra (margine superiore)
    rows << { type: :empty, height: cell_size }

    # Riga dividendo | divisore
    rows << build_dividend_divisor_row(left_cols, right_cols, total_cols, cell_size)

    # Righe passi intermedi (prodotti, resti, abbassamenti)
    # La prima riga con q>0 include anche il quoziente sulla destra
    first_significant_shown = false
    display_steps.each_with_index do |step, display_idx|
      is_significant = step[:quotient_digit] > 0
      is_last_step = (display_idx == display_steps.length - 1)

      if is_significant
        # Step con q>0: mostra prodotto
        if !first_significant_shown
          # Prima riga step significativo: Prodotto | Quoziente
          rows << build_product_row_with_quotient(step, display_idx, left_cols, right_cols, total_cols, cell_size)
          first_significant_shown = true
        else
          # Righe successive: Prodotto | vuoto
          rows << build_product_row(step, display_idx, left_cols, right_cols, total_cols, cell_size)
        end
      end
      # Step con q=0: NON mostra prodotto, solo la riga resto sotto

      # Riga resto (se c'è bring_down, resto > 0, oppure è l'ultimo step per mostrare resto finale)
      if step[:bring_down].present? || step[:remainder] > 0 || is_last_step
        next_step_has_bring_down = step[:bring_down].present?
        rows << build_remainder_row(step, display_idx, left_cols, right_cols, total_cols, cell_size, next_step_has_bring_down)
      end
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
      show_steps_button: true,  # Solo divisione ha il pulsante "Mostra Passi"
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

    # Separatore verticale (cella vuota con bordo spesso a sinistra)
    # Il divisore inizia subito dopo, quindi questa cella contiene la prima cifra del divisore
    # Per spostare il divisore a sinistra, mettiamo le cifre subito dopo il separatore

    # Divisore (allineato a sinistra, inizia dalla colonna separatore)
    divisor_digs.each_with_index do |digit, idx|
      pos_from_right = divisor_digs.length - 1 - idx
      show_comma = @divisor_decimals > 0 && pos_from_right == @divisor_decimals

      cell = {
        type: :digit,
        value: digit,
        target: "input",
        editable: true,
        row: 0,
        col: left_cols + idx,
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

    # Padding destra divisore (inclusa la cella che era il separatore)
    padding_right = right_cols - divisor_digs.length + 1  # +1 per il separatore
    padding_right.times { cells << { type: :empty } }

    # Margine destro
    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells, separator_col: left_cols + 1 }
  end

  # Prima riga prodotto con quoziente sulla destra
  def build_product_row_with_quotient(step, step_idx, left_cols, right_cols, total_cols, cell_size)
    cells = []
    product_str = step[:product].to_s
    product_digits = product_str.chars
    quot_digits = quotient_digits
    decimal_pos = quotient_decimal_position

    # Posizione del prodotto
    product_end = step[:step_index] + 3
    product_start = product_end - product_digits.length
    minus_position = product_start - 1

    # Costruisci tutte le celle
    (1 + left_cols + 1 + right_cols + 1).times do |col|
      if col == 0
        cells << { type: :empty }
      elsif col <= left_cols
        left_col = col - 1
        if col == minus_position
          cells << {
            type: :sign,
            value: "-",
            classes: "text-gray-500 dark:text-gray-400"
          }
        elsif col >= product_start && col < product_end
          digit_idx = col - product_start
          cells << {
            type: :digit,
            value: product_digits[digit_idx],
            target: "step",
            editable: true,
            row: 1 + step_idx * 2,
            col: left_col,
            show_value: @show_steps,
            classes: "text-red-600 dark:text-red-400",
            nav_direction: "ltr"
          }
        else
          cells << { type: :empty }
        end
      elsif col <= left_cols + right_cols
        # Colonna destra - quoziente (inizia subito dopo left_cols, senza separatore vuoto)
        right_col = col - left_cols - 1  # Indice nella colonna destra
        if right_col >= 0 && right_col < quot_digits.length
          pos_from_right = quot_digits.length - 1 - right_col
          is_correct_comma_position = decimal_pos > 0 && pos_from_right == decimal_pos
          can_have_comma_spot = decimal_pos > 0 && pos_from_right > 0 && pos_from_right < quot_digits.length

          cell = {
            type: :digit,
            value: quot_digits[right_col],
            target: "result",
            editable: true,
            row: 1,
            col: left_cols + right_col,
            show_value: @show_solution,
            classes: "text-blue-600 dark:text-blue-400",
            nav_direction: "ltr",
            thick_border_top: true
          }

          if can_have_comma_spot
            cell[:comma_spot] = {
              correct: is_correct_comma_position,
              position: pos_from_right
            }
          end

          cells << cell
        else
          # Celle vuote a destra del quoziente hanno comunque il bordo sopra
          cells << { type: :empty, thick_border_top: true }
        end
      else
        cells << { type: :empty }
      end
    end

    { type: :cells, height: cell_size, cells: cells, separator_col: left_cols + 1 }
  end

  def build_product_row(step, step_idx, left_cols, right_cols, total_cols, cell_size)
    cells = []
    product_str = step[:product].to_s
    product_digits = product_str.chars

    # Posizione del prodotto: allineato a destra rispetto alla posizione corrente nel dividendo
    # Come nel vecchio partial: product_end = 1 + step_index + 1, product_start = product_end - length
    # Ma qui abbiamo un margine sinistro (col 0), quindi aggiungiamo 1 a tutte le posizioni
    product_end = step[:step_index] + 3  # +1 margine, +1 base_padding, +1 allineamento
    product_start = product_end - product_digits.length
    minus_position = product_start - 1  # Segno "-" prima delle cifre

    # Costruisci tutte le celle (margine sinistro + left_cols + separatore + right_cols + margine destro)
    (1 + left_cols + 1 + right_cols + 1).times do |col|
      if col == 0
        # Margine sinistro
        cells << { type: :empty }
      elsif col <= left_cols
        # Colonna sinistra (col 1 a left_cols)
        left_col = col - 1  # Indice nella colonna sinistra (0-based)
        if col == minus_position
          # Segno meno
          cells << {
            type: :sign,
            value: "-",
            classes: "text-gray-500 dark:text-gray-400"
          }
        elsif col >= product_start && col < product_end
          # Cifra del prodotto
          digit_idx = col - product_start
          cells << {
            type: :digit,
            value: product_digits[digit_idx],
            target: "step",
            editable: true,
            row: 1 + step_idx * 2,
            col: left_col,
            show_value: @show_steps,
            classes: "text-red-600 dark:text-red-400",
            nav_direction: "ltr"
          }
        else
          cells << { type: :empty }
        end
      elsif col == left_cols + 1
        # Separatore
        cells << { type: :empty }
      elsif col <= left_cols + 1 + right_cols
        # Colonna destra vuota
        cells << { type: :empty }
      else
        # Margine destro
        cells << { type: :empty }
      end
    end

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

    # Posizione del resto: come nel vecchio partial ma con margine sinistro
    # base_padding = 1 (spazio per il segno -), +1 per margine sinistro
    # con bring_down: remainder_end = 1 + 1 + step_index + 2
    # senza bring_down: remainder_end = 1 + 1 + step_index + 1
    if has_bring_down
      remainder_end = step[:step_index] + 4  # +1 margine, +1 base_padding, +2 per bring_down
    else
      remainder_end = step[:step_index] + 3  # +1 margine, +1 base_padding, +1 allineamento
    end
    remainder_start = remainder_end - combined_digits.length

    # Costruisci tutte le celle (margine sinistro + left_cols + separatore + right_cols + margine destro)
    (1 + left_cols + 1 + right_cols + 1).times do |col|
      if col == 0
        # Margine sinistro
        cells << { type: :empty }
      elsif col <= left_cols
        # Colonna sinistra (col 1 a left_cols)
        left_col = col - 1  # Indice nella colonna sinistra (0-based)
        if col >= remainder_start && col < remainder_end
          digit_idx = col - remainder_start
          is_bring_down_digit = has_bring_down && digit_idx == combined_digits.length - 1

          cells << {
            type: :digit,
            value: combined_digits[digit_idx],
            target: "step",
            editable: true,
            row: 2 + step_idx * 2,
            col: left_col,
            show_value: @show_steps,
            classes: is_bring_down_digit ? "text-gray-500 dark:text-gray-400" : "text-green-600 dark:text-green-400",
            nav_direction: "ltr"
          }
        else
          cells << { type: :empty }
        end
      elsif col == left_cols + 1
        # Separatore
        cells << { type: :empty }
      elsif col <= left_cols + 1 + right_cols
        # Colonna destra vuota
        cells << { type: :empty }
      else
        # Margine destro
        cells << { type: :empty }
      end
    end

    { type: :cells, height: cell_size, cells: cells, separator_col: left_cols + 1 }
    end
  end
end
