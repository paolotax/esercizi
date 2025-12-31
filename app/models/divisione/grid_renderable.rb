# frozen_string_literal: true

# Metodi per il rendering della griglia quaderno per divisioni
# Genera la matrice per il partial unificato _quaderno_grid
# Layout divisione italiana:
#   dividendo | divisore
#   ----------|----------
#             | quoziente
#   resti...  |
module Divisione::GridRenderable
  extend ActiveSupport::Concern

  # Parametri da passare al partial
  def to_partial_params
    { divisione: self }
  end

  # Stringa dell'operazione (es. "144 : 12 =")
  def operation_string
    "#{raw_dividend} : #{raw_divisor} ="
  end

  # Genera la matrice per il partial unificato _quaderno_grid
  def to_grid_matrix
    left_cols = left_column_width
    right_cols = right_column_width
    total_cols = left_cols + right_cols + 1

    cell_size = "2.5em"
    steps = division_steps

    display_steps = steps.reject.with_index { |s, i| i == 0 && s[:quotient_digit] == 0 }

    rows = []

    rows << { type: :empty, height: cell_size }
    rows << build_dividend_divisor_row(left_cols, right_cols, total_cols, cell_size)

    first_significant_shown = false
    display_steps.each_with_index do |step, display_idx|
      is_significant = step[:quotient_digit] > 0
      is_last_step = (display_idx == display_steps.length - 1)

      if is_significant
        if !first_significant_shown
          rows << build_product_row_with_quotient(step, display_idx, left_cols, right_cols, total_cols, cell_size)
          first_significant_shown = true
        else
          rows << build_product_row(step, display_idx, left_cols, right_cols, total_cols, cell_size)
        end
      end

      if step[:bring_down].present? || step[:remainder] > 0 || is_last_step
        next_step_has_bring_down = step[:bring_down].present?
        rows << build_remainder_row(step, display_idx, left_cols, right_cols, total_cols, cell_size, next_step_has_bring_down)
      end
    end

    rows << { type: :empty, height: cell_size }
    rows << { type: :toolbar } if show_toolbar?

    # Titolo: usa operation_string se operandi nascosti, altrimenti title esplicito
    display_title = show_dividend_divisor? ? title : (title.presence || operation_string)

    {
      columns: total_cols,
      cell_size: cell_size,
      controller: "quaderno",
      title: display_title,
      show_toolbar: show_toolbar?,
      show_steps_button: true,
      separator_col: left_cols,
      remainder: has_remainder? ? remainder : nil,
      operation_type: :divisione,
      border_color: "orange",
      rows: rows
    }
  end

  private

  # Metodi helper per opzioni con defaults
  def show_dividend_divisor?
    show_dividend_divisor.nil? ? true : show_dividend_divisor
  end

  def show_solution?
    show_solution.nil? ? false : show_solution
  end

  def show_toolbar?
    show_toolbar.nil? ? true : show_toolbar
  end

  def show_steps?
    show_steps.nil? ? false : show_steps
  end

  def build_dividend_divisor_row(left_cols, right_cols, total_cols, cell_size)
    cells = []
    div_digits = raw_dividend_digits
    divisor_digs = raw_divisor_digits

    padding_left = left_cols - div_digits.length
    padding_left.times { cells << { type: :empty } }

    div_digits.each_with_index do |digit, idx|
      pos_from_right = div_digits.length - 1 - idx
      show_comma = dividend_decimals > 0 && pos_from_right == dividend_decimals - decimal_shift

      cell = {
        type: :digit,
        value: digit,
        target: "input",
        editable: true,
        row: 0,
        col: padding_left + idx,
        show_value: show_dividend_divisor?,
        classes: "text-gray-800 dark:text-gray-100",
        nav_direction: "ltr"
      }

      if dividend_decimals > 0 && pos_from_right == dividend_decimals
        cell[:comma_shift] = {
          type: "dividend",
          position: idx,
          should_shift: decimal_shift > 0
        }
      end

      cells << cell
    end

    divisor_digs.each_with_index do |digit, idx|
      pos_from_right = divisor_digs.length - 1 - idx
      show_comma = divisor_decimals > 0 && pos_from_right == divisor_decimals

      cell = {
        type: :digit,
        value: digit,
        target: "input",
        editable: true,
        row: 0,
        col: left_cols + idx,
        show_value: show_dividend_divisor?,
        classes: "text-gray-800 dark:text-gray-100",
        nav_direction: "ltr"
      }

      if show_comma
        cell[:comma_shift] = {
          type: "divisor",
          position: idx,
          should_shift: decimal_shift > 0
        }
      end

      cells << cell
    end

    padding_right = right_cols - divisor_digs.length
    padding_right.times { cells << { type: :empty } } if padding_right > 0

    cells << { type: :empty }

    { type: :cells, height: cell_size, cells: cells, separator_col: left_cols }
  end

  def build_product_row_with_quotient(step, step_idx, left_cols, right_cols, total_cols, cell_size)
    cells = []
    product_str = step[:product].to_s
    product_digits = product_str.chars
    quot_digits = quotient_digits
    decimal_pos = quotient_decimal_position

    product_end = step[:step_index] + 2
    product_start = product_end - product_digits.length
    minus_position = product_start - 1

    (left_cols + right_cols + 1).times do |col|
      if col < left_cols
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
            col: col,
            show_value: show_steps?,
            classes: "text-red-600 dark:text-red-400",
            nav_direction: "ltr"
          }
        else
          cells << { type: :empty }
        end
      elsif col < left_cols + right_cols
        right_col = col - left_cols
        if right_col < quot_digits.length
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
            show_value: show_solution?,
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
          cells << { type: :empty, thick_border_top: true }
        end
      else
        cells << { type: :empty }
      end
    end

    { type: :cells, height: cell_size, cells: cells, separator_col: left_cols }
  end

  def build_product_row(step, step_idx, left_cols, right_cols, total_cols, cell_size)
    cells = []
    product_str = step[:product].to_s
    product_digits = product_str.chars

    product_end = step[:step_index] + 2
    product_start = product_end - product_digits.length
    minus_position = product_start - 1

    (left_cols + right_cols + 1).times do |col|
      if col < left_cols
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
            col: col,
            show_value: show_steps?,
            classes: "text-red-600 dark:text-red-400",
            nav_direction: "ltr"
          }
        else
          cells << { type: :empty }
        end
      elsif col < left_cols + right_cols
        cells << { type: :empty }
      else
        cells << { type: :empty }
      end
    end

    { type: :cells, height: cell_size, cells: cells, separator_col: left_cols }
  end

  def build_remainder_row(step, step_idx, left_cols, right_cols, total_cols, cell_size, has_bring_down)
    cells = []
    remainder_val = step[:remainder]
    bring_down = step[:bring_down]

    if has_bring_down
      combined = remainder_val.to_s + bring_down.to_s
    else
      combined = remainder_val.to_s
    end
    combined_digits = combined.chars

    if has_bring_down
      remainder_end = step[:step_index] + 3
    else
      remainder_end = step[:step_index] + 2
    end
    remainder_start = remainder_end - combined_digits.length

    (left_cols + right_cols + 1).times do |col|
      if col < left_cols
        if col >= remainder_start && col < remainder_end
          digit_idx = col - remainder_start
          is_bring_down_digit = has_bring_down && digit_idx == combined_digits.length - 1

          cells << {
            type: :digit,
            value: combined_digits[digit_idx],
            target: "step",
            editable: true,
            row: 2 + step_idx * 2,
            col: col,
            show_value: show_steps?,
            classes: is_bring_down_digit ? "text-gray-500 dark:text-gray-400" : "text-green-600 dark:text-green-400",
            nav_direction: "ltr"
          }
        else
          cells << { type: :empty }
        end
      elsif col < left_cols + right_cols
        cells << { type: :empty }
      else
        cells << { type: :empty }
      end
    end

    { type: :cells, height: cell_size, cells: cells, separator_col: left_cols }
  end
end
