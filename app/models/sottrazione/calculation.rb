# frozen_string_literal: true

require "bigdecimal"

# Logica di calcolo per sottrazioni
# Può essere usato sia dal model AR che dal Renderer
module Sottrazione::Calculation
  extend ActiveSupport::Concern

  # Normalizza una stringa numerica: accetta virgola o punto come separatore
  def normalize_number_string(value)
    return value.to_s if value.is_a?(Integer)
    str = value.to_s.strip
    str.gsub(",", ".")
  end

  # Converte stringa in numero (Integer o BigDecimal per precisione)
  def parse_to_number(str)
    str.to_s.include?(".") ? BigDecimal(str) : str.to_i
  end

  # Minuendo normalizzato come stringa
  def raw_minuend
    @raw_minuend ||= normalize_number_string(minuend)
  end

  # Sottraendo normalizzato come stringa
  def raw_subtrahend
    @raw_subtrahend ||= normalize_number_string(subtrahend)
  end

  # Minuendo come numero
  def parsed_minuend
    @parsed_minuend ||= parse_to_number(raw_minuend)
  end

  # Sottraendo come numero
  def parsed_subtrahend
    @parsed_subtrahend ||= parse_to_number(raw_subtrahend)
  end

  # Calcola il numero massimo di cifre decimali
  def decimal_places
    @decimal_places ||= [ raw_minuend, raw_subtrahend ].map do |str|
      str.include?(".") ? str.split(".").last.length : 0
    end.max
  end

  # Verifica se l'operazione ha decimali
  def has_decimals?
    decimal_places > 0
  end

  # Calcola il numero massimo di cifre intere
  def max_integer_digits
    @max_integer_digits ||= begin
      all_numbers = [ parsed_minuend, parsed_subtrahend, result ]
      all_numbers.map { |n| n.abs.to_i.to_s.length }.max
    end
  end

  # Alias per compatibilità
  def max_digits
    max_integer_digits
  end

  # Calcola il risultato della sottrazione
  def result
    @result ||= parsed_minuend - parsed_subtrahend
  end

  # Cifre del minuendo per il layout (formattate)
  def minuend_digits
    @minuend_digits ||= format_number_digits(raw_minuend)
  end

  # Cifre del sottraendo per il layout (formattate)
  def subtrahend_digits
    @subtrahend_digits ||= format_number_digits(raw_subtrahend)
  end

  # Cifre del risultato per il layout
  def result_digits
    @result_digits ||= begin
      if has_decimals?
        result_str = format("%.#{decimal_places}f", result)
        format_number_digits(result_str)
      else
        result_str = result.to_s
        result_padding = max_integer_digits - result_str.length
        ([ "" ] * result_padding) + result_str.chars
      end
    end
  end

  # Formatta un numero in array di cifre
  def format_number_digits(raw_str)
    if has_decimals?
      if raw_str.include?(".")
        int_part, dec_part = raw_str.split(".")
      else
        int_part = raw_str
        dec_part = "0" * decimal_places
      end

      # Padding parte intera a sinistra
      int_digits = int_part.chars
      int_padding = max_integer_digits - int_digits.length
      int_cells = ([ "" ] * int_padding) + int_digits

      # Padding parte decimale a destra
      dec_digits = dec_part.chars
      dec_padding = decimal_places - dec_digits.length
      dec_cells = dec_digits + ([ "0" ] * dec_padding)

      int_cells + dec_cells
    else
      num_str = raw_str.to_s
      padding = max_integer_digits - num_str.length
      ([ "" ] * padding) + num_str.chars
    end
  end

  # Calcola i prestiti per ogni colonna (da destra a sinistra)
  # Gestisce correttamente i prestiti a catena (es. 100 - 1)
  def borrows
    @borrows ||= begin
      total_cols = max_integer_digits + decimal_places
      borrows_array = Array.new(total_cols, "")

      minuend_digs = minuend_digits.reject { |d| d == "," }.map { |d| d.present? ? d.to_i : 0 }
      subtrahend_digs = subtrahend_digits.reject { |d| d == "," }.map { |d| d.present? ? d.to_i : 0 }
      borrowed_minuend = minuend_digs.dup

      (total_cols - 1).downto(0) do |col_idx|
        minuend_digit = borrowed_minuend[col_idx]
        subtrahend_digit = subtrahend_digs[col_idx]

        if minuend_digit < subtrahend_digit && col_idx > 0
          borrowed_minuend[col_idx] += 10

          lender_col = col_idx - 1
          while lender_col >= 0 && borrowed_minuend[lender_col] == 0
            borrowed_minuend[lender_col] = 9
            lender_col -= 1
          end

          if lender_col >= 0
            borrowed_minuend[lender_col] -= 1
            borrows_array[lender_col] = borrowed_minuend[lender_col].to_s
          end

          ((lender_col + 1)..(col_idx - 1)).each do |intermediate_col|
            borrows_array[intermediate_col] = borrowed_minuend[intermediate_col].to_s
          end
        end
      end

      borrows_array
    end
  end

  # Indica quali cifre del minuendo sono state "usate" (hanno prestato o ricevuto)
  def crossed_out
    @crossed_out ||= begin
      total_cols = max_integer_digits + decimal_places
      crossed_out_array = Array.new(total_cols, false)

      minuend_digs = minuend_digits.reject { |d| d == "," }.map { |d| d.present? ? d.to_i : 0 }
      subtrahend_digs = subtrahend_digits.reject { |d| d == "," }.map { |d| d.present? ? d.to_i : 0 }
      borrowed_minuend = minuend_digs.dup

      (total_cols - 1).downto(0) do |col_idx|
        minuend_digit = borrowed_minuend[col_idx]
        subtrahend_digit = subtrahend_digs[col_idx]

        if minuend_digit < subtrahend_digit && col_idx > 0
          borrowed_minuend[col_idx] += 10

          lender_col = col_idx - 1
          while lender_col >= 0 && borrowed_minuend[lender_col] == 0
            borrowed_minuend[lender_col] = 9
            crossed_out_array[lender_col] = true
            lender_col -= 1
          end

          if lender_col >= 0
            borrowed_minuend[lender_col] -= 1
            crossed_out_array[lender_col] = true
          end
        end
      end

      crossed_out_array
    end
  end

  # Reset dei valori calcolati (da chiamare quando cambiano i dati)
  def reset_calculations!
    @raw_minuend = nil
    @raw_subtrahend = nil
    @parsed_minuend = nil
    @parsed_subtrahend = nil
    @decimal_places = nil
    @max_integer_digits = nil
    @result = nil
    @minuend_digits = nil
    @subtrahend_digits = nil
    @result_digits = nil
    @borrows = nil
    @crossed_out = nil
  end
end
