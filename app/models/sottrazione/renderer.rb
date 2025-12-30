# frozen_string_literal: true

require "bigdecimal"

class Sottrazione
  # Renderer per rappresentare una sottrazione in colonna
  # Supporta sia numeri interi che decimali (con virgola)
  #
  # Usa SottrazioneCalculation per la logica di calcolo (condivisa con il model AR)
  class Renderer
    include Sottrazione::Calculation

    attr_accessor :minuend, :subtrahend
    attr_reader :title, :show_exercise, :show_minuend_subtrahend, :show_solution, :show_toolbar, :show_borrow, :show_labels, :grid_style

    def initialize(minuend:, subtrahend:, **options)
      @minuend = minuend
      @subtrahend = subtrahend

      # Opzioni di visualizzazione
      @title = options[:title]
      @show_exercise = options.fetch(:show_exercise, true)
      @show_minuend_subtrahend = options.fetch(:show_minuend_subtrahend, false)
      @show_solution = options.fetch(:show_solution, false)
      @show_toolbar = options.fetch(:show_toolbar, false)
      @show_borrow = options.fetch(:show_borrow, true)
      @show_labels = options.fetch(:show_labels, false)
      @grid_style = options.fetch(:grid_style, :quaderno) # :quaderno o :column
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

    # Colori per le etichette del quaderno (con dark mode)
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

    # Etichette delle colonne (compatibilità)
    def column_labels
      quaderno_labels
    end

    # Colori per le etichette delle colonne (compatibilità)
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

    # Stile CSS per il grid
    def grid_style
      "display: grid; grid-template-columns: repeat(#{max_digits}, 4rem); gap: 0;"
    end

    # Parametri da passare al partial
    def to_partial_params
      { sottrazione: self }
    end

    # Stringa per display (es: "487 - 258")
    def to_s
      "#{parsed_minuend} - #{parsed_subtrahend}"
    end

    # Genera la matrice per il partial unificato _quaderno_grid
    def to_grid_matrix
      column_types = quaderno_column_types
      total_cols = column_types.length + 2
      cell_size = "2.5em"
      borrow_height = "1.5em"

      rows = []

      rows << build_labels_row(column_types, total_cols, cell_size)
      rows << build_borrow_row(column_types, total_cols, borrow_height) if @show_borrow
      rows << build_minuend_row(column_types, total_cols, cell_size)
      rows << build_subtrahend_row(column_types, total_cols, cell_size)
      rows << build_result_row(column_types, total_cols, cell_size)
      rows << { type: :empty, height: cell_size }
      rows << { type: :toolbar } if @show_toolbar

      {
        columns: total_cols,
        cell_size: cell_size,
        controller: "quaderno",
        title: @title,
        show_toolbar: @show_toolbar,
        style: @grid_style,
        operation_type: :sottrazione,
        border_color: "red",
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

    def build_borrow_row(column_types, total_cols, borrow_height)
      cells = []
      borrows_arr = borrows
      borrow_counter = 0
      col_index = 0

      cells << { type: :empty }
      col_index += 1

      column_types.each do |col_type|
        case col_type
        when :sign
          cells << { type: :empty }
        when :comma
          cells << { type: :empty }
        else
          borrow_value = borrows_arr[borrow_counter] || ""
          is_last_digit_col = has_decimals? ? (borrow_counter == borrows_arr.length - 1) : (borrow_counter == max_integer_digits - 1)

          cells << {
            type: :digit,
            value: borrow_value.to_s,
            target: "carry",
            editable: true,
            disabled: is_last_digit_col,
            show_value: @show_solution && borrow_value.present?,
            classes: "text-red-600 dark:text-red-400",
            bg_class: is_last_digit_col ? "" : "bg-red-50 dark:bg-red-900/30",
            nav_direction: "ltr",
            col: col_index
          }
          borrow_counter += 1
        end
        col_index += 1
      end

      cells << { type: :empty }
      { type: :cells, height: borrow_height, cells: cells }
    end

    def build_minuend_row(column_types, total_cols, cell_size)
      cells = []
      minuend_digs = minuend_digits
      digit_counter = 0
      col_index = 0

      cells << { type: :empty }
      col_index += 1

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
            nav_direction: "ltr",
            col: col_index
          }
          digit_counter += 1
        end
        col_index += 1
      end

      cells << { type: :empty }
      { type: :cells, height: cell_size, cells: cells }
    end

    def build_subtrahend_row(column_types, total_cols, cell_size)
      cells = []
      subtrahend_digs = subtrahend_digits
      digit_counter = 0

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

      cells << { type: :empty }
      { type: :cells, height: cell_size, cells: cells }
    end

    def build_result_row(column_types, total_cols, cell_size)
      cells = []
      result_digs = result_digits
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

      cells << { type: :empty }
      { type: :result, height: cell_size, cells: cells, thick_border_top: true }
    end
  end
end
