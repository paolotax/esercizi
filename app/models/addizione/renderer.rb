# frozen_string_literal: true

require "bigdecimal"

class Addizione
  # Renderer per rappresentare un'operazione in colonna (addizione o sottrazione)
  # Supporta sia numeri interi che decimali (con virgola)
  #
  # Usa AddizioneCalculation per la logica di calcolo (condivisa con il model AR)
  class Renderer
    include AddizioneCalculation

    attr_accessor :addends, :operator
    attr_reader :title, :show_exercise, :show_addends, :show_solution, :show_toolbar, :show_carry,
                :show_addend_indices, :show_labels

    def initialize(addends:, operator: "+", **options)
      @addends = Array(addends)
      @operator = operator

      # Opzioni di visualizzazione
      @title = options[:title]
      @show_exercise = options.fetch(:show_exercise, true)
      @show_addends = options.fetch(:show_addends, false)
      @show_solution = options.fetch(:show_solution, false)
      @show_toolbar = options.fetch(:show_toolbar, false)
      @show_carry = options.fetch(:show_carry, true)
      @show_addend_indices = options[:show_addend_indices]
      @show_labels = options.fetch(:show_labels, false)
    end

    # Alias per compatibilità con vecchio codice
    def parsed_addends
      @parsed_addends ||= raw_addends.map { |s| parse_to_number(s) }
    end

    # Numero totale di colonne per il layout quaderno (cifre intere + virgola + cifre decimali + segno)
    def quaderno_columns
      cols = max_integer_digits
      cols += 1 + decimal_places if has_decimals?
      cols += 1
      cols
    end

    # Tipi di colonna per il layout quaderno: :digit, :comma, :sign
    def quaderno_column_types
      types = Array.new(max_integer_digits, :digit)
      if has_decimals?
        types << :comma
        types += Array.new(decimal_places, :digit)
      end
      types << :sign
      types
    end

    # Cifre di un addendo per il layout quaderno (include virgola come ",")
    def quaderno_addend_digits(addend_index)
      num = parsed_addends[addend_index]
      raw = raw_addends[addend_index]

      if has_decimals?
        if raw.include?(".")
          int_part, dec_part = raw.split(".")
        else
          int_part = raw
          dec_part = "0" * decimal_places
        end

        int_digits = int_part.chars
        int_padding = max_integer_digits - int_digits.length
        int_cells = ([""] * int_padding) + int_digits

        comma_cell = [","]

        dec_digits = dec_part.chars
        dec_padding = decimal_places - dec_digits.length
        dec_cells = dec_digits + (["0"] * dec_padding)

        int_cells + comma_cell + dec_cells
      else
        num_str = num.to_s
        padding = max_integer_digits - num_str.length
        ([""] * padding) + num_str.chars
      end
    end

    # Cifre del risultato per il layout quaderno
    def quaderno_result_digits
      if has_decimals?
        result_str = format("%.#{decimal_places}f", result)
        int_part, dec_part = result_str.split(".")

        int_digits = int_part.chars
        int_padding = max_integer_digits - int_digits.length
        int_cells = ([""] * int_padding) + int_digits

        comma_cell = [","]
        dec_cells = dec_part.chars

        int_cells + comma_cell + dec_cells
      else
        result_str = result.to_s
        result_padding = max_integer_digits - result_str.length
        ([""] * result_padding) + result_str.chars
      end
    end

    # Riporti per il layout quaderno (esclude la colonna virgola)
    def quaderno_carries
      total_digit_cols = max_integer_digits + decimal_places
      carries_array = Array.new(total_digit_cols, "")
      carry = 0

      (total_digit_cols - 1).downto(0) do |col_idx|
        column_sum = carry

        parsed_addends.each_with_index do |_, addend_idx|
          digits = quaderno_addend_digits(addend_idx)
          digit_idx = col_idx < max_integer_digits ? col_idx : col_idx + 1
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

      if has_decimals?
        carries_array.insert(max_integer_digits, "")
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

    # Etichette delle colonne (da sinistra a destra)
    def column_labels
      labels = []

      labels << "M" if max_digits >= 7
      labels << "hk" if max_digits >= 6
      labels << "dak" if max_digits >= 5
      labels << "uk" if max_digits >= 4
      labels << "h" if max_digits >= 3
      labels << "da" if max_digits >= 2
      labels << "u"

      while labels.length < max_digits
        labels.unshift("")
      end

      labels
    end

    # Colori per le etichette delle colonne
    def column_colors
      colors = []

      colors << "text-purple-600" if max_digits >= 7
      colors << "text-orange-600" if max_digits >= 6
      colors << "text-yellow-600" if max_digits >= 5
      colors << "text-pink-600" if max_digits >= 4
      colors << "text-green-600" if max_digits >= 3
      colors << "text-red-500" if max_digits >= 2
      colors << "text-blue-600"

      while colors.length < max_digits
        colors.unshift("text-gray-400")
      end

      colors
    end

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
      end

      labels
    end

    # Colori per le etichette del quaderno (include decimali)
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
      end

      colors
    end

    # Stile CSS per il grid
    def grid_style
      "display: grid; grid-template-columns: repeat(#{max_digits}, 4rem); gap: 0;"
    end

    # Parametri da passare al partial
    def to_partial_params
      { addizione: self }
    end

    # Stringa per display (es: "234 + 1234")
    def to_s
      parsed_addends.join(" #{operator} ")
    end

    # Genera la matrice per il partial unificato _quaderno_grid
    def to_grid_matrix
      column_types = quaderno_column_types
      total_cols = column_types.length + 2
      cell_size = "2.5em"
      carry_height = "1.5em"

      rows = []

      rows << build_labels_row(column_types, total_cols, cell_size)
      rows << build_carry_row(column_types, total_cols, carry_height) if @show_carry
      parsed_addends.each_with_index do |_, addend_idx|
        rows << build_addend_row(addend_idx, column_types, total_cols, cell_size)
      end
      rows << build_result_row(column_types, total_cols, cell_size)
      rows << { type: :empty, height: cell_size }
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

      cells << { type: :empty }
      { type: :cells, height: cell_size, cells: cells }
    end

    def build_carry_row(column_types, total_cols, carry_height)
      cells = []
      carries_arr = quaderno_carries
      carry_counter = 0

      cells << { type: :empty }

      column_types.each do |col_type|
        case col_type
        when :sign
          cells << { type: :empty }
        when :comma
          cells << { type: :empty }
          carry_counter += 1
        else
          carry_value = carries_arr[carry_counter] || ""
          is_last_digit_col = has_decimals? ? (carry_counter == carries_arr.length - 1) : (carry_counter == max_integer_digits - 1)

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

      cells << { type: :empty }
      { type: :cells, height: carry_height, cells: cells }
    end

    def build_addend_row(addend_idx, column_types, total_cols, cell_size)
      cells = []
      digits = quaderno_addend_digits(addend_idx)
      digit_counter = 0

      cells << { type: :empty }

      column_types.each do |col_type|
        case col_type
        when :sign
          sign_value = addend_idx == parsed_addends.length - 1 ? "=" : operator
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

      cells << { type: :empty }
      { type: :cells, height: cell_size, cells: cells }
    end

    def build_result_row(column_types, total_cols, cell_size)
      cells = []
      result_digits_arr = quaderno_result_digits
      result_counter = 0

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

      cells << { type: :empty }
      { type: :result, height: cell_size, cells: cells, thick_border_top: true }
    end
  end
end
