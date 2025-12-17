# frozen_string_literal: true

require "bigdecimal"

# Modello per rappresentare una sottrazione in colonna
# Supporta sia numeri interi che decimali (con virgola)
class Sottrazione
  attr_reader :minuend, :subtrahend, :result, :max_digits,
              :title, :show_exercise, :show_minuend_subtrahend, :show_solution, :show_toolbar, :show_borrow, :show_labels,
              :decimal_places, :max_integer_digits, :raw_minuend, :raw_subtrahend

  def initialize(minuend:, subtrahend:, **options)
    @raw_minuend = normalize_number_string(minuend)
    @raw_subtrahend = normalize_number_string(subtrahend)
    @decimal_places = calculate_decimal_places
    @minuend = parse_to_number(@raw_minuend)
    @subtrahend = parse_to_number(@raw_subtrahend)
    @result = calculate_result
    @max_integer_digits = calculate_max_integer_digits
    @max_digits = @max_integer_digits # Per compatibilità con il codice esistente

    # Opzioni di visualizzazione
    @title = options[:title]
    @show_exercise = options.fetch(:show_exercise, true)
    @show_minuend_subtrahend = options.fetch(:show_minuend_subtrahend, false)
    @show_solution = options.fetch(:show_solution, false)
    @show_toolbar = options.fetch(:show_toolbar, false)
    @show_borrow = options.fetch(:show_borrow, true)
    @show_labels = options.fetch(:show_labels, false)
  end

  # Normalizza una stringa numerica: accetta virgola o punto come separatore
  def normalize_number_string(value)
    return value.to_s if value.is_a?(Integer)
    str = value.to_s.strip
    # Converti virgola in punto per parsing interno
    str.gsub(",", ".")
  end

  # Converte stringa in numero (Integer o BigDecimal per precisione)
  def parse_to_number(str)
    str.include?(".") ? BigDecimal(str) : str.to_i
  end

  # Calcola il numero massimo di cifre decimali
  def calculate_decimal_places
    [ @raw_minuend, @raw_subtrahend ].map do |str|
      if str.include?(".")
        str.split(".").last.length
      else
        0
      end
    end.max
  end

  # Calcola il numero massimo di cifre intere
  def calculate_max_integer_digits
    all_numbers = [ @minuend, @subtrahend, @result ]
    all_numbers.map { |n| n.abs.to_i.to_s.length }.max
  end

  # Verifica se l'operazione ha decimali
  def has_decimals?
    @decimal_places > 0
  end

  # Tipi di colonna per il layout quaderno: :digit, :comma, :sign
  def quaderno_column_types
    types = Array.new(@max_integer_digits, :digit)
    if has_decimals?
      types << :comma
      types += Array.new(@decimal_places, :digit)
    end
    types << :sign
    types
  end

  # Etichette per il quaderno (include decimali)
  def quaderno_labels
    labels = []

    # Multipli (parte intera)
    labels << "M" if @max_integer_digits >= 7    # Milioni
    labels << "hk" if @max_integer_digits >= 6   # Centinaia di migliaia
    labels << "dak" if @max_integer_digits >= 5  # Decine di migliaia
    labels << "uk" if @max_integer_digits >= 4   # Unità di migliaia
    labels << "h" if @max_integer_digits >= 3    # Centinaia
    labels << "da" if @max_integer_digits >= 2   # Decine
    labels << "u"                                 # Unità (sempre presente)

    # Padding per avere sempre max_integer_digits etichette
    while labels.length < @max_integer_digits
      labels.unshift("")
    end

    # Sottomultipli (parte decimale)
    if has_decimals?
      labels << "d" if @decimal_places >= 1   # Decimi
      labels << "c" if @decimal_places >= 2   # Centesimi
      labels << "m" if @decimal_places >= 3   # Millesimi
    end

    labels
  end

  # Colori per le etichette del quaderno (con dark mode)
  def quaderno_label_colors
    colors = []

    # Colori multipli (parte intera)
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

    # Colori sottomultipli (parte decimale)
    if has_decimals?
      colors << "text-cyan-600 dark:text-cyan-400" if @decimal_places >= 1   # Decimi
      colors << "text-teal-600 dark:text-teal-400" if @decimal_places >= 2   # Centesimi
      colors << "text-emerald-600 dark:text-emerald-400" if @decimal_places >= 3 # Millesimi
    end

    colors
  end

  # Parsing di una stringa come "487 - 258" o "12,34 - 5,67"
  def self.parse(operation_string)
    return nil if operation_string.blank?

    # Rimuovi spazi e split per operatore meno
    parts = operation_string.gsub(/\s+/, "").split(/[-=]/)

    # Estrai i due numeri (supporta decimali con virgola o punto)
    numbers = parts.map { |p| p if p.match?(/^\d+([.,]\d+)?$/) }.compact

    return nil if numbers.length < 2

    new(minuend: numbers[0], subtrahend: numbers[1])
  end

  # Parsing di più operazioni separate da punto e virgola o newline
  # NOTA: la virgola NON è più un separatore perché usata per i decimali
  def self.parse_multiple(operations_string)
    return [] if operations_string.blank?

    operations_string
      .split(/[;\n]/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |op| parse(op) }
      .compact
  end

  # Calcola il risultato della sottrazione
  def calculate_result
    @minuend - @subtrahend
  end

  # Cifre del minuendo per il layout quaderno (include virgola)
  def minuend_digits
    format_number_digits(@raw_minuend)
  end

  # Cifre del sottraendo per il layout quaderno (include virgola)
  def subtrahend_digits
    format_number_digits(@raw_subtrahend)
  end

  # Cifre del risultato per il layout quaderno
  def result_digits
    if has_decimals?
      result_str = format("%.#{@decimal_places}f", @result)
      format_number_digits(result_str)
    else
      result_str = @result.to_s
      result_padding = @max_integer_digits - result_str.length
      ([ "" ] * result_padding) + result_str.chars
    end
  end

  # Formatta un numero in array di cifre per il quaderno
  def format_number_digits(raw_str)
    if has_decimals?
      if raw_str.include?(".")
        int_part, dec_part = raw_str.split(".")
      else
        int_part = raw_str
        dec_part = "0" * @decimal_places
      end

      # Padding parte intera a sinistra
      int_digits = int_part.chars
      int_padding = @max_integer_digits - int_digits.length
      int_cells = ([ "" ] * int_padding) + int_digits

      # Padding parte decimale a destra
      dec_digits = dec_part.chars
      dec_padding = @decimal_places - dec_digits.length
      dec_cells = dec_digits + ([ "0" ] * dec_padding)

      int_cells + dec_cells
    else
      num_str = raw_str.to_s
      padding = @max_integer_digits - num_str.length
      ([ "" ] * padding) + num_str.chars
    end
  end

  # Calcola i prestiti per ogni colonna (da destra a sinistra)
  # Gestisce correttamente i prestiti a catena (es. 100 - 1)
  def borrows
    total_cols = @max_integer_digits + @decimal_places
    borrows_array = Array.new(total_cols, "")

    minuend_digs = minuend_digits.reject { |d| d == "," }.map { |d| d.present? ? d.to_i : 0 }
    subtrahend_digs = subtrahend_digits.reject { |d| d == "," }.map { |d| d.present? ? d.to_i : 0 }
    borrowed_minuend = minuend_digs.dup

    (total_cols - 1).downto(0) do |col_idx|
      minuend_digit = borrowed_minuend[col_idx]
      subtrahend_digit = subtrahend_digs[col_idx]

      # Se minuendo < sottraendo, serve un prestito
      if minuend_digit < subtrahend_digit && col_idx > 0
        borrowed_minuend[col_idx] += 10

        # Cerca la prima colonna a sinistra che può prestare (valore > 0)
        lender_col = col_idx - 1
        while lender_col >= 0 && borrowed_minuend[lender_col] == 0
          # Questa colonna è 0, deve prendere in prestito dalla precedente
          borrowed_minuend[lender_col] = 9  # Prende 10 e presta 1, rimane 9
          lender_col -= 1
        end

        # La colonna che presta effettivamente decrementa di 1
        if lender_col >= 0
          borrowed_minuend[lender_col] -= 1
          borrows_array[lender_col] = borrowed_minuend[lender_col].to_s
        end

        # Aggiorna anche le colonne intermedie che hanno "prestato attraverso"
        ((lender_col + 1)..(col_idx - 1)).each do |intermediate_col|
          borrows_array[intermediate_col] = borrowed_minuend[intermediate_col].to_s
        end
      end
    end

    borrows_array
  end

  # Indica quali cifre del minuendo sono state "usate" (hanno prestato o ricevuto)
  # Restituisce true per le cifre che devono apparire sbiadite
  def crossed_out
    total_cols = @max_integer_digits + @decimal_places
    crossed_out_array = Array.new(total_cols, false)

    minuend_digs = minuend_digits.reject { |d| d == "," }.map { |d| d.present? ? d.to_i : 0 }
    subtrahend_digs = subtrahend_digits.reject { |d| d == "," }.map { |d| d.present? ? d.to_i : 0 }
    borrowed_minuend = minuend_digs.dup

    (total_cols - 1).downto(0) do |col_idx|
      minuend_digit = borrowed_minuend[col_idx]
      subtrahend_digit = subtrahend_digs[col_idx]

      if minuend_digit < subtrahend_digit && col_idx > 0
        borrowed_minuend[col_idx] += 10

        # Cerca la prima colonna a sinistra che può prestare (valore > 0)
        lender_col = col_idx - 1
        while lender_col >= 0 && borrowed_minuend[lender_col] == 0
          borrowed_minuend[lender_col] = 9
          crossed_out_array[lender_col] = true  # Questa colonna ha "cambiato" il suo valore
          lender_col -= 1
        end

        if lender_col >= 0
          borrowed_minuend[lender_col] -= 1
          crossed_out_array[lender_col] = true  # La colonna che presta
        end
      end
    end

    crossed_out_array
  end

  # Etichette delle colonne (compatibilità)
  def column_labels
    quaderno_labels
  end

  # Colori per le etichette delle colonne (compatibilità)
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

  # Genera la matrice per il partial unificato _quaderno_grid
  def to_grid_matrix
    column_types = quaderno_column_types
    total_cols = column_types.length + 2 # +2 per colonne vuote ai lati
    cell_size = "2.5em"
    borrow_height = "1.5em"

    rows = []

    # Riga etichette o vuota sopra
    rows << build_labels_row(column_types, total_cols, cell_size)

    # Riga dei prestiti
    rows << build_borrow_row(column_types, total_cols, borrow_height) if @show_borrow

    # Riga del minuendo
    rows << build_minuend_row(column_types, total_cols, cell_size)

    # Riga del sottraendo
    rows << build_subtrahend_row(column_types, total_cols, cell_size)

    # Riga del risultato
    rows << build_result_row(column_types, total_cols, cell_size)

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
      rows: rows
    }
  end

  private

  def build_labels_row(column_types, total_cols, cell_size)
    cells = []

    # Cella vuota sinistra
    cells << { type: :empty }

    if @show_labels
      labels = quaderno_labels
      label_colors = quaderno_label_colors
      label_idx = 0

      column_types.each do |col_type|
        case col_type
        when :sign
          cells << { type: :empty }
        when :comma
          cells << { type: :label, value: ",", classes: "" }
        else
          cells << { type: :label, value: labels[label_idx], classes: label_colors[label_idx] }
          label_idx += 1
        end
      end
    else
      column_types.length.times { cells << { type: :empty } }
    end

    # Cella vuota destra
    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells }
  end

  def build_borrow_row(column_types, total_cols, borrow_height)
    cells = []
    borrows_arr = borrows
    borrow_counter = 0

    # Cella vuota sinistra
    cells << { type: :empty }

    column_types.each do |col_type|
      case col_type
      when :sign
        cells << { type: :empty }
      when :comma
        cells << { type: :empty }
      else
        borrow_value = borrows_arr[borrow_counter] || ""
        is_last_digit_col = has_decimals? ? (borrow_counter == borrows_arr.length - 1) : (borrow_counter == @max_integer_digits - 1)

        cells << {
          type: :digit,
          value: borrow_value.to_s,
          target: "carry",
          editable: true,
          disabled: is_last_digit_col,
          show_value: @show_solution && borrow_value.present?,
          classes: "text-red-600 dark:text-red-400",
          bg_class: is_last_digit_col ? "" : "bg-red-50 dark:bg-red-900/30",
          nav_direction: "ltr"
        }
        borrow_counter += 1
      end
    end

    # Cella vuota destra
    cells << { type: :empty }

    { type: :cells, height: borrow_height, cells: cells }
  end

  def build_minuend_row(column_types, total_cols, cell_size)
    cells = []
    minuend_digs = minuend_digits
    digit_counter = 0

    # Cella vuota sinistra
    cells << { type: :empty }

    column_types.each do |col_type|
      case col_type
      when :sign
        cells << {
          type: :sign,
          value: "-",
          classes: "text-red-600 dark:text-red-400"
        }
      when :comma
        cells << {
          type: :digit,
          value: ",",
          target: "input",
          editable: true,
          show_value: @show_minuend_subtrahend,
          classes: "text-gray-700 dark:text-gray-300",
          nav_direction: "ltr"
        }
      else
        digit = minuend_digs[digit_counter] || ""

        cells << {
          type: :digit,
          value: digit,
          target: "input",
          editable: true,
          show_value: @show_minuend_subtrahend && digit.present?,
          classes: "text-gray-800 dark:text-gray-100",
          nav_direction: "ltr"
        }
        digit_counter += 1
      end
    end

    # Cella vuota destra
    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells }
  end

  def build_subtrahend_row(column_types, total_cols, cell_size)
    cells = []
    subtrahend_digs = subtrahend_digits
    digit_counter = 0

    # Cella vuota sinistra
    cells << { type: :empty }

    column_types.each do |col_type|
      case col_type
      when :sign
        cells << {
          type: :sign,
          value: "=",
          classes: "text-red-600 dark:text-red-400"
        }
      when :comma
        cells << {
          type: :digit,
          value: ",",
          target: "input",
          editable: true,
          show_value: @show_minuend_subtrahend,
          classes: "text-gray-700 dark:text-gray-300",
          nav_direction: "ltr"
        }
      else
        digit = subtrahend_digs[digit_counter] || ""

        cells << {
          type: :digit,
          value: digit,
          target: "input",
          editable: true,
          show_value: @show_minuend_subtrahend && digit.present?,
          classes: "text-gray-800 dark:text-gray-100",
          nav_direction: "ltr"
        }
        digit_counter += 1
      end
    end

    # Cella vuota destra
    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells }
  end

  def build_result_row(column_types, total_cols, cell_size)
    cells = []
    result_digs = result_digits
    result_counter = 0

    # Cella vuota sinistra
    cells << { type: :empty }

    column_types.each do |col_type|
      case col_type
      when :sign
        cells << { type: :empty }
      when :comma
        cells << {
          type: :digit,
          value: ",",
          target: "result",
          editable: true,
          show_value: @show_solution,
          classes: "text-gray-700 dark:text-gray-300",
          nav_direction: "rtl"
        }
      else
        digit = result_digs[result_counter] || ""

        cells << {
          type: :digit,
          value: digit,
          target: "result",
          editable: true,
          show_value: @show_solution && digit.present?,
          classes: "text-gray-800 dark:text-gray-100",
          nav_direction: "rtl"
        }
        result_counter += 1
      end
    end

    # Cella vuota destra
    cells << { type: :empty }

    { type: :result, height: cell_size, cells: cells, thick_border_top: true }
  end
end
