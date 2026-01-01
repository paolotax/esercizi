# frozen_string_literal: true

# Metodi per il rendering della griglia quaderno per moltiplicazioni
# Genera la matrice per il partial unificato _quaderno_grid
module Moltiplicazione::GridRenderable
  extend ActiveSupport::Concern

  # Etichette per il quaderno (include decimali)
  def quaderno_labels
    labels = []

    labels << "M" if max_integer_digits >= 7
    labels << "hk" if max_integer_digits >= 6
    labels << "dak" if max_integer_digits >= 5
    labels << "uk" if max_integer_digits >= 4
    labels << "h" if max_integer_digits >= 3
    labels << "da" if max_integer_digits >= 2
    labels << "u"

    while labels.length < max_integer_digits
      labels.unshift("")
    end

    if has_decimals?
      labels << "d" if decimal_places >= 1
      labels << "c" if decimal_places >= 2
      labels << "m" if decimal_places >= 3
      (decimal_places - 3).times { labels << "" } if decimal_places > 3
    end

    labels
  end

  # Colori per le etichette del quaderno
  def quaderno_label_colors
    colors = []

    colors << "text-purple-600 dark:text-purple-400" if max_integer_digits >= 7
    colors << "text-orange-600 dark:text-orange-400" if max_integer_digits >= 6
    colors << "text-yellow-600 dark:text-yellow-400" if max_integer_digits >= 5
    colors << "text-pink-600 dark:text-pink-400" if max_integer_digits >= 4
    colors << "text-green-600 dark:text-green-400" if max_integer_digits >= 3
    colors << "text-red-500 dark:text-red-400" if max_integer_digits >= 2
    colors << "text-blue-600 dark:text-blue-400"

    while colors.length < max_integer_digits
      colors.unshift("text-gray-400 dark:text-gray-500")
    end

    if has_decimals?
      colors << "text-cyan-600 dark:text-cyan-400" if decimal_places >= 1
      colors << "text-teal-600 dark:text-teal-400" if decimal_places >= 2
      colors << "text-emerald-600 dark:text-emerald-400" if decimal_places >= 3
      (decimal_places - 3).times { colors << "text-gray-400 dark:text-gray-500" } if decimal_places > 3
    end

    colors
  end

  # Cifre del moltiplicando per il quaderno (senza virgola, allineate a destra)
  def quaderno_multiplicand_digits
    format_number_for_grid(raw_multiplicand)
  end

  # Cifre del moltiplicatore per il quaderno (senza virgola, allineate a destra)
  def quaderno_multiplier_digits
    format_number_for_grid(raw_multiplier)
  end

  # Cifre del risultato per il quaderno
  def quaderno_result_digits
    if has_decimals?
      result_str = format("%.#{decimal_places}f", product)
      format_number_for_grid(result_str)
    else
      result_str = product.to_s
      padding = max_digits - result_str.length
      ([ "" ] * padding) + result_str.chars
    end
  end

  # Formatta un numero per la griglia (allineato a destra, senza virgola)
  def format_number_for_grid(raw_str)
    digits_only = raw_str.gsub(".", "")
    total_digits = max_digits
    padding = total_digits - digits_only.length
    ([ "" ] * padding) + digits_only.chars
  end

  # Posizione della virgola per un numero specifico (da destra, 0-indexed)
  def comma_position_for_number(raw_str)
    return nil unless raw_str.include?(".")
    raw_str.split(".").last.length
  end

  # Dati per i prodotti parziali nel formato quaderno
  def quaderno_partial_products
    return [] unless multiplier_length > 1

    mult_digits = multiplier_digits.reverse
    mult_digits.each_with_index.map do |digit, row_index|
      multiplicand_int = raw_multiplicand.gsub(".", "").to_i
      partial_product = multiplicand_int * digit
      partial_str = partial_product.to_s

      zeros = row_index
      digits = partial_str.chars
      cols_for_digits = max_digits - zeros
      padding = cols_for_digits - digits.length
      padded_digits = ([ "" ] * padding) + digits

      carries = calculate_partial_carries(digit)
      carries_length = cols_for_digits - 1
      padded_carries = ([ "" ] * (carries_length - carries.length)) + carries.map { |c| c || "" }

      {
        digits: padded_digits,
        carries: padded_carries,
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

        multiplicand_int = raw_multiplicand.gsub(".", "").to_i
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

  # Parametri da passare al partial
  def to_partial_params
    { moltiplicazione: self }
  end

  # Stringa dell'operazione (es. "45 × 12 =")
  def operation_string
    "#{raw_multiplicand} × #{raw_multiplier} ="
  end

  # Genera la matrice per il partial unificato _quaderno_grid
  def to_grid_matrix
    data_cols = max_digits
    total_cols = data_cols + 3
    cell_size = "2.5em"
    carry_height = "1.5em"
    has_partials = multiplier_length > 1

    rows = []

    rows << build_labels_row(data_cols, total_cols, cell_size)
    rows << build_single_digit_carry_row(data_cols, total_cols, carry_height) if show_carry? && !has_partials
    rows << build_multiplicand_row(data_cols, total_cols, cell_size)
    rows << build_multiplier_row(data_cols, total_cols, cell_size)

    if has_partials
      quaderno_partial_products.each_with_index do |partial, p_idx|
        rows << build_partial_carry_row(partial, data_cols, total_cols, carry_height, p_idx) if show_carry?
        rows << build_partial_product_row(partial, data_cols, total_cols, cell_size, p_idx, !show_carry? && p_idx == 0)
      end
      rows << build_sum_carry_row(data_cols, total_cols, carry_height) if show_carry?
    end

    rows << build_result_row(data_cols, total_cols, cell_size)
    rows << { type: :empty, height: cell_size }
    rows << { type: :toolbar } if show_toolbar?

    # Titolo: usa operation_string se operandi nascosti, altrimenti title esplicito
    display_title = show_multiplicand_multiplier? ? title : (title.presence || operation_string)

    {
      columns: total_cols,
      cell_size: cell_size,
      controller: "quaderno",
      title: display_title,
      show_toolbar: show_toolbar?,
      show_steps_button: has_partials,
      style: grid_style,
      operation_type: :moltiplicazione,
      border_color: "green",
      rows: rows
    }
  end

  private

  # Metodi helper per opzioni con defaults
  def show_multiplicand_multiplier?
    show_multiplicand_multiplier.nil? ? true : show_multiplicand_multiplier
  end

  def show_solution?
    show_solution.nil? ? false : show_solution
  end

  def show_toolbar?
    show_toolbar.nil? ? true : show_toolbar
  end

  def show_carry?
    show_carry.nil? ? true : show_carry
  end

  def show_labels?
    return false if has_decimals?
    return true if grid_style.to_s == "column"
    show_labels.nil? ? false : show_labels
  end

  def show_partial_products?
    show_partial_products.nil? ? false : show_partial_products
  end

  def show_steps?
    # Per moltiplicazione, show_steps viene mappato a show_partial_products
    show_partial_products.nil? ? false : show_partial_products
  end

  def grid_style
    respond_to?(:grid_style_value) ? grid_style_value : :quaderno
  end

  def build_labels_row(data_cols, total_cols, cell_size)
    cells = []
    cells << { type: :empty }

    if show_labels?
      labels = quaderno_labels
      label_colors = quaderno_label_colors
      data_cols.times do |idx|
        cells << { type: :label, value: labels[idx], classes: label_colors[idx] }
      end
    else
      data_cols.times { cells << { type: :empty } }
    end

    cells << { type: :empty }
    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells }
  end

  def build_single_digit_carry_row(data_cols, total_cols, carry_height)
    cells = []
    carries = result_carries
    # I riporti sono allineati alle prime n-1 colonne (tutte tranne le unità)
    # carries[0] = sopra la prima colonna di dati, carries[last] = sopra la penultima

    cells << { type: :empty }

    data_cols.times do |digit_idx|
      is_last = digit_idx == max_digits - 1
      # Le colonne delle unità (is_last) non hanno mai riporti sopra
      carry_value = (!is_last && digit_idx < carries.length) ? carries[digit_idx] : nil

      cells << {
        type: :digit,
        value: carry_value.to_s,
        target: "carry",
        editable: true,
        disabled: is_last,
        show_value: show_solution? && carry_value.present?,
        classes: "text-green-600 dark:text-green-400",
        bg_class: is_last ? "" : "bg-green-50 dark:bg-green-900/30",
        nav_direction: "ltr"
      }
    end

    cells << { type: :empty }
    cells << { type: :empty }

    { type: :cells, height: carry_height, cells: cells }
  end

  def build_multiplicand_row(data_cols, total_cols, cell_size)
    cells = []
    digits = quaderno_multiplicand_digits

    cells << { type: :empty }

    digits.each_with_index do |digit, idx|
      pos_from_right = data_cols - 1 - idx
      is_correct_comma_position = multiplicand_decimals > 0 && pos_from_right == multiplicand_decimals
      can_have_comma_spot = has_decimals? && !show_multiplicand_multiplier? && pos_from_right > 0 && pos_from_right < data_cols

      cell = {
        type: :digit,
        value: digit,
        target: "input",
        editable: true,
        show_value: show_multiplicand_multiplier? && digit.present?,
        show_comma: is_correct_comma_position && show_multiplicand_multiplier?,
        classes: "text-gray-800 dark:text-gray-100",
        nav_direction: "ltr"
      }

      # Aggiungi comma_spot quando operandi nascosti e ci sono decimali
      if can_have_comma_spot
        cell[:comma_spot] = {
          correct: is_correct_comma_position,
          position: pos_from_right,
          group: "multiplicand"
        }
      end

      cells << cell
    end

    cells << {
      type: :sign,
      value: "×",
      classes: "text-green-600 dark:text-green-400"
    }
    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells }
  end

  def build_multiplier_row(data_cols, total_cols, cell_size)
    cells = []
    digits = quaderno_multiplier_digits
    has_partials = multiplier_length > 1

    cells << { type: :empty }

    digits.each_with_index do |digit, idx|
      pos_from_right = data_cols - 1 - idx
      is_correct_comma_position = multiplier_decimals > 0 && pos_from_right == multiplier_decimals
      can_have_comma_spot = has_decimals? && !show_multiplicand_multiplier? && pos_from_right > 0 && pos_from_right < data_cols

      cell = {
        type: :digit,
        value: digit,
        target: "input",
        editable: true,
        show_value: show_multiplicand_multiplier? && digit.present?,
        show_comma: is_correct_comma_position && show_multiplicand_multiplier?,
        classes: "text-gray-800 dark:text-gray-100",
        nav_direction: "ltr"
      }

      # Aggiungi comma_spot quando operandi nascosti e ci sono decimali
      if can_have_comma_spot
        cell[:comma_spot] = {
          correct: is_correct_comma_position,
          position: pos_from_right,
          group: "multiplier"
        }
      end

      cells << cell
    end

    cells << {
      type: :sign,
      value: "=",
      classes: "text-green-600 dark:text-green-400"
    }
    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells, thick_border_bottom: has_partials }
  end

  def build_partial_carry_row(partial, data_cols, total_cols, carry_height, p_idx)
    cells = []
    zeros = partial[:zeros]
    carries = partial[:carries]
    first_partial_top_border = p_idx == 0

    cells << { type: :empty }

    data_cols.times do |col_idx|
      col_from_right = data_cols - 1 - col_idx
      is_zero_column = col_from_right < zeros
      cols_with_data = data_cols - zeros
      is_last_data_col = col_idx == cols_with_data - 1
      carry_idx = col_idx
      carry_value = (carries && carry_idx < carries.length) ? carries[carry_idx] : nil

      if is_zero_column || is_last_data_col
        cells << { type: :empty }
      else
        cells << {
          type: :digit,
          value: carry_value.to_s,
          target: "step",
          editable: true,
          is_carry: true,
          show_value: show_steps? && carry_value.present?,
          classes: "text-orange-600 dark:text-orange-400",
          bg_class: "bg-orange-50 dark:bg-orange-900/30",
          nav_direction: "ltr"
        }
      end
    end

    cells << { type: :empty }
    cells << { type: :empty }

    { type: :cells, height: carry_height, cells: cells, thick_border_top: first_partial_top_border }
  end

  def build_partial_product_row(partial, data_cols, total_cols, cell_size, p_idx, thick_border_top)
    cells = []
    is_last_partial = p_idx == quaderno_partial_products.length - 1

    cells << { type: :empty }

    data_cols.times do |digit_idx|
      digit = partial[:digits][digit_idx]
      col_from_right = data_cols - 1 - digit_idx
      is_zero_placeholder = col_from_right < partial[:zeros]

      if is_zero_placeholder
        cells << {
          type: :static,
          value: "0",
          classes: "text-gray-400 dark:text-gray-500"
        }
      else
        cells << {
          type: :digit,
          value: digit,
          target: "step",
          editable: true,
          show_value: show_steps? && digit.present?,
          classes: "text-gray-800 dark:text-gray-100",
          nav_direction: "rtl"
        }
      end
    end

    # Segno: + per prodotti parziali intermedi, = per l'ultimo
    cells << {
      type: :sign,
      value: is_last_partial ? "=" : "+",
      classes: "text-green-600 dark:text-green-400"
    }
    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells, thick_border_top: thick_border_top }
  end

  def build_sum_carry_row(data_cols, total_cols, carry_height)
    cells = []
    sum_carries = quaderno_sum_carries

    cells << { type: :empty }

    sum_carries.each_with_index do |carry, carry_idx|
      is_last = carry_idx == sum_carries.length - 1

      cells << {
        type: :digit,
        value: carry.to_s,
        target: "carry",
        editable: true,
        disabled: is_last,
        show_value: show_solution? && carry.present?,
        classes: "text-green-600 dark:text-green-400",
        bg_class: is_last ? "" : "bg-green-50 dark:bg-green-900/30",
        nav_direction: "ltr"
      }
    end

    cells << { type: :empty }
    cells << { type: :empty }

    { type: :cells, height: carry_height, cells: cells }
  end

  def build_result_row(data_cols, total_cols, cell_size)
    cells = []
    result_digs = quaderno_result_digits

    cells << { type: :empty }

    result_digs.each_with_index do |digit, idx|
      pos_from_right = data_cols - 1 - idx
      is_correct_comma_position = decimal_places > 0 && pos_from_right == decimal_places
      can_have_comma_spot = has_decimals? && pos_from_right > 0 && pos_from_right < data_cols

      cell = {
        type: :digit,
        value: digit,
        target: "result",
        editable: true,
        show_value: show_solution? && digit.present?,
        classes: "text-gray-800 dark:text-gray-100",
        nav_direction: "rtl"
      }

      if can_have_comma_spot
        cell[:comma_spot] = {
          correct: is_correct_comma_position,
          position: pos_from_right,
          group: "result"
        }
      end

      cells << cell
    end

    cells << { type: :empty }
    cells << { type: :empty }

    { type: :result, height: cell_size, cells: cells, thick_border_top: true }
  end
end
