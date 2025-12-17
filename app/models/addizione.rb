# frozen_string_literal: true

require "bigdecimal"

# Modello per rappresentare un'operazione in colonna (addizione o sottrazione)
# Supporta sia numeri interi che decimali (con virgola)
class Addizione
  attr_reader :addends, :operator, :result, :max_digits,
              :title, :show_exercise, :show_addends, :show_solution, :show_toolbar, :show_carry,
              :show_addend_indices, :decimal_places, :max_integer_digits,
              :raw_addends, :show_labels # Memorizza gli addendi originali come stringhe

  def initialize(addends:, operator: "+", **options)
    # Normalizza gli addendi: converte stringhe con virgola in float
    @raw_addends = addends.map { |a| normalize_number_string(a) }
    @decimal_places = calculate_decimal_places
    @addends = @raw_addends.map { |s| parse_to_number(s) }
    @operator = operator
    @result = calculate_result
    @max_integer_digits = calculate_max_integer_digits
    @max_digits = @max_integer_digits # Per compatibilità con il codice esistente

    # Opzioni di visualizzazione
    @title = options[:title]
    @show_exercise = options.fetch(:show_exercise, true)
    @show_addends = options.fetch(:show_addends, false)
    @show_solution = options.fetch(:show_solution, false)
    @show_toolbar = options.fetch(:show_toolbar, false)
    @show_carry = options.fetch(:show_carry, true)
    # Array di indici degli addendi da mostrare (es: [0] per mostrare solo il primo)
    # Se nil, usa show_addends per tutti
    @show_addend_indices = options[:show_addend_indices]
    @show_labels = options.fetch(:show_labels, false)
  end

  # Normalizza una stringa numerica: accetta virgola o punto come separatore
  def normalize_number_string(value)
    return value.to_s if value.is_a?(Integer)
    str = value.to_s.strip
    # Converti virgola in punto per parsing interno, ma mantieni la stringa originale
    str.gsub(",", ".")
  end

  # Converte stringa in numero (Integer o BigDecimal per precisione)
  def parse_to_number(str)
    str.include?(".") ? BigDecimal(str) : str.to_i
  end

  # Calcola il numero massimo di cifre decimali tra tutti gli addendi e il risultato
  def calculate_decimal_places
    max_decimals = @raw_addends.map do |str|
      if str.include?(".")
        str.split(".").last.length
      else
        0
      end
    end.max
    max_decimals || 0
  end

  # Calcola il numero massimo di cifre intere
  def calculate_max_integer_digits
    all_numbers = @addends + [ @result ]
    all_numbers.map { |n| n.abs.to_i.to_s.length }.max
  end

  # Verifica se l'operazione ha decimali
  def has_decimals?
    @decimal_places > 0
  end

  # Numero totale di colonne per il layout quaderno (cifre intere + virgola + cifre decimali + segno)
  def quaderno_columns
    cols = @max_integer_digits
    cols += 1 + @decimal_places if has_decimals? # +1 per la virgola
    cols += 1 # colonna per il segno
    cols
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

  # Cifre di un addendo per il layout quaderno (include virgola come ",")
  def quaderno_addend_digits(addend_index)
    num = @addends[addend_index]
    raw = @raw_addends[addend_index]

    if has_decimals?
      # Separa parte intera e decimale
      if raw.include?(".")
        int_part, dec_part = raw.split(".")
      else
        int_part = raw
        dec_part = "0" * @decimal_places
      end

      # Padding parte intera a sinistra
      int_digits = int_part.chars
      int_padding = @max_integer_digits - int_digits.length
      int_cells = ([ "" ] * int_padding) + int_digits

      # Virgola
      comma_cell = [ "," ]

      # Padding parte decimale a destra
      dec_digits = dec_part.chars
      dec_padding = @decimal_places - dec_digits.length
      dec_cells = dec_digits + ([ "0" ] * dec_padding)

      int_cells + comma_cell + dec_cells
    else
      # Solo numeri interi
      num_str = num.to_s
      padding = @max_integer_digits - num_str.length
      ([ "" ] * padding) + num_str.chars
    end
  end

  # Cifre del risultato per il layout quaderno
  def quaderno_result_digits
    if has_decimals?
      # Formatta il risultato con le cifre decimali corrette
      result_str = format("%.#{@decimal_places}f", @result)
      int_part, dec_part = result_str.split(".")

      # Padding parte intera a sinistra
      int_digits = int_part.chars
      int_padding = @max_integer_digits - int_digits.length
      int_cells = ([ "" ] * int_padding) + int_digits

      # Virgola
      comma_cell = [ "," ]

      # Parte decimale (già della lunghezza giusta)
      dec_cells = dec_part.chars

      int_cells + comma_cell + dec_cells
    else
      # Solo numeri interi
      result_str = @result.to_s
      result_padding = @max_integer_digits - result_str.length
      ([ "" ] * result_padding) + result_str.chars
    end
  end

  # Riporti per il layout quaderno (esclude la colonna virgola)
  def quaderno_carries
    total_digit_cols = @max_integer_digits + @decimal_places
    carries_array = Array.new(total_digit_cols, "")
    carry = 0

    # Calcola i riporti da destra a sinistra (partendo dai decimali)
    (total_digit_cols - 1).downto(0) do |col_idx|
      column_sum = carry

      @addends.each_with_index do |_, addend_idx|
        digits = quaderno_addend_digits(addend_idx)
        # Salta la virgola nel calcolo
        digit_idx = col_idx < @max_integer_digits ? col_idx : col_idx + 1
        digit_val = digits[digit_idx].to_i
        column_sum += digit_val
      end

      if column_sum >= 10
        carry = column_sum / 10
        carries_array[col_idx - 1] = carry.to_s if col_idx > 0
      else
        carry = 0
      end
    end

    # Inserisci cella vuota per la virgola
    if has_decimals?
      carries_array.insert(@max_integer_digits, "")
    end

    carries_array
  end

  # Verifica se un addendo specifico deve essere mostrato
  def show_addend?(index)
    if @show_addend_indices
      @show_addend_indices.include?(index)
    else
      @show_addends
    end
  end

  # Parsing di una stringa come "234 + 1234" o "12,34 + 5,67"
  def self.parse(operation_string)
    return nil if operation_string.blank?

    # Rimuovi spazi e split per operatori
    parts = operation_string.gsub(/\s+/, "").split(/([+\-=])/)

    # Estrai numeri e operatore (supporta decimali con virgola o punto)
    numbers = []
    operator = "+"

    parts.each do |part|
      if part.match?(/^\d+([.,]\d+)?$/)
        # Mantieni come stringa per preservare i decimali
        numbers << part
      elsif part.match?(/^[+\-]$/)
        operator = part
      end
    end

    return nil if numbers.empty?

    new(addends: numbers, operator: operator)
  end

  # Parsing di più operazioni separate da punto e virgola o newline
  # NOTA: la virgola NON è più un separatore perché usata per i decimali (es: 12,34)
  def self.parse_multiple(operations_string)
    return [] if operations_string.blank?

    operations_string
      .split(/[;\n]/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |op| parse(op) }
      .compact
  end

  # Calcola il risultato dell'operazione
  def calculate_result
    case @operator
    when "+"
      @addends.sum
    when "-"
      @addends[0] - @addends[1..-1].sum
    else
      @addends.sum
    end
  end

  # Calcola i riporti per ogni colonna (da destra a sinistra)
  def carries
    carries_array = Array.new(@max_digits, "")
    carry = 0

    (@max_digits - 1).downto(0) do |col_idx|
      # Somma tutti i digit di questa colonna
      column_sum = carry
      addends_digits.each do |digits|
        digit_val = digits[col_idx].to_i
        column_sum += digit_val
      end

      # Se la somma è >= 10, c'è un riporto
      if column_sum >= 10
        carry = column_sum / 10
        # Il riporto va nella colonna precedente (a sinistra)
        carries_array[col_idx - 1] = carry.to_s if col_idx > 0
      else
        carry = 0
      end
    end

    carries_array
  end

  # Converti ogni addendo in array di cifre (da sinistra a destra)
  # Gli zeri non significativi vengono sostituiti con stringhe vuote
  def addends_digits
    @addends.map do |num|
      num_str = num.to_s
      padding = @max_digits - num_str.length
      # Crea array con celle vuote per gli zeri non significativi
      ([ "" ] * padding) + num_str.chars
    end
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

  # Colori per le etichette del quaderno (include decimali)
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

  # Stile CSS per il grid
  def grid_style
    "display: grid; grid-template-columns: repeat(#{@max_digits}, 4rem); gap: 0;"
  end

  # Parametri da passare al partial - semplicemente l'oggetto stesso
  def to_partial_params
    { addizione: self }
  end

  # Stringa per display (es: "234 + 1234")
  def to_s
    @addends.join(" #{@operator} ")
  end

  # Genera la matrice per il partial unificato _quaderno_grid
  def to_grid_matrix
    column_types = quaderno_column_types
    total_cols = column_types.length + 2 # +2 per colonne vuote ai lati
    cell_size = "2.5em"
    carry_height = "1.5em"

    rows = []

    # Riga etichette o vuota sopra
    rows << build_labels_row(column_types, total_cols, cell_size)

    # Riga dei riporti
    rows << build_carry_row(column_types, total_cols, carry_height) if @show_carry

    # Righe degli addendi
    @addends.each_with_index do |_, addend_idx|
      rows << build_addend_row(addend_idx, column_types, total_cols, cell_size)
    end

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

  def build_carry_row(column_types, total_cols, carry_height)
    cells = []
    carries = quaderno_carries
    carry_counter = 0

    # Cella vuota sinistra
    cells << { type: :empty }

    column_types.each do |col_type|
      case col_type
      when :sign
        cells << { type: :empty }
      when :comma
        cells << { type: :empty }
        carry_counter += 1
      else
        carry_value = carries[carry_counter] || ""
        is_last_digit_col = has_decimals? ? (carry_counter == carries.length - 1) : (carry_counter == @max_integer_digits - 1)

        cells << {
          type: :digit,
          value: carry_value.to_s,
          target: "carry",
          editable: true,
          disabled: is_last_digit_col,
          show_value: @show_solution && carry_value.present?,
          classes: "text-blue-600 dark:text-blue-400",
          bg_class: is_last_digit_col ? "" : "bg-blue-50 dark:bg-blue-900/30",
          nav_direction: "ltr"
        }
        carry_counter += 1
      end
    end

    # Cella vuota destra
    cells << { type: :empty }

    { type: :cells, height: carry_height, cells: cells }
  end

  def build_addend_row(addend_idx, column_types, total_cols, cell_size)
    cells = []
    digits = quaderno_addend_digits(addend_idx)
    digit_counter = 0

    # Cella vuota sinistra
    cells << { type: :empty }

    column_types.each do |col_type|
      case col_type
      when :sign
        sign_value = if addend_idx == @addends.length - 1
                       "="
                     else
                       @operator
                     end
        cells << {
          type: :sign,
          value: sign_value,
          classes: "text-blue-600 dark:text-blue-400"
        }
      when :comma
        cells << {
          type: :digit,
          value: ",",
          target: "input",
          editable: true,
          show_value: show_addend?(addend_idx),
          classes: "text-gray-700 dark:text-gray-300",
          nav_direction: "ltr"
        }
        digit_counter += 1
      else
        digit = digits[digit_counter] || ""
        digit = "" if digit == ","

        cells << {
          type: :digit,
          value: digit,
          target: "input",
          editable: true,
          show_value: show_addend?(addend_idx) && digit.present?,
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
    result_digits_arr = quaderno_result_digits
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
        result_counter += 1
      else
        digit = result_digits_arr[result_counter] || ""
        digit = "" if digit == ","

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
