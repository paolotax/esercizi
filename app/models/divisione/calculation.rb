# frozen_string_literal: true

require "bigdecimal"

# Logica di calcolo per divisioni (metodo italiano)
# Può essere usato sia dal model AR che dal Renderer
module Divisione::Calculation
  extend ActiveSupport::Concern

  # Normalizza una stringa numerica: accetta virgola o punto come separatore
  def normalize_number_string(value)
    return value.to_s if value.is_a?(Integer)
    str = value.to_s.strip
    str.gsub(",", ".")
  end

  # Conta le cifre decimali di una stringa numerica
  def count_decimals(str)
    str.include?(".") ? str.split(".").last.length : 0
  end

  # Converte un numero decimale in intero spostando la virgola
  def to_integer_shifted(str, shift)
    decimals = count_decimals(str)
    digits_only = str.gsub(".", "")
    zeros_to_add = shift - decimals
    if zeros_to_add > 0
      digits_only += "0" * zeros_to_add
    end
    digits_only.to_i
  end

  # Dividendo normalizzato come stringa
  def raw_dividend
    @raw_dividend ||= normalize_number_string(dividend)
  end

  # Divisore normalizzato come stringa
  def raw_divisor
    @raw_divisor ||= normalize_number_string(divisor)
  end

  # Decimali nel dividendo
  def dividend_decimals
    @dividend_decimals ||= count_decimals(raw_dividend)
  end

  # Decimali nel divisore
  def divisor_decimals
    @divisor_decimals ||= count_decimals(raw_divisor)
  end

  # Shift decimale (quante posizioni spostare la virgola per rendere il divisore intero)
  def decimal_shift
    @decimal_shift ||= divisor_decimals
  end

  # Dividendo come intero (dopo lo shift)
  def parsed_dividend
    @parsed_dividend ||= to_integer_shifted(raw_dividend, decimal_shift)
  end

  # Divisore come intero (dopo lo shift)
  def parsed_divisor
    @parsed_divisor ||= to_integer_shifted(raw_divisor, decimal_shift)
  end

  # Quoziente
  def quotient
    @quotient ||= parsed_dividend / parsed_divisor
  end

  # Resto
  def remainder
    @remainder ||= parsed_dividend % parsed_divisor
  end

  # Alias per compatibilità
  def result
    quotient
  end

  # Verifica se l'operazione ha decimali
  def has_decimals?
    dividend_decimals > 0 || divisor_decimals > 0
  end

  # Posizione della virgola nel quoziente (da destra)
  def quotient_decimal_position
    extra_dividend_decimals = dividend_decimals - divisor_decimals
    base_decimals = extra_dividend_decimals > 0 ? extra_dividend_decimals : 0
    base_decimals + extra_zeros_count
  end

  # Numero di zeri extra per continuare la divisione
  def extra_zeros_count
    respond_to?(:extra_zeros) && extra_zeros.present? ? extra_zeros.to_i : 0
  end

  # Numero di cifre del dividendo
  def dividend_length
    parsed_dividend.to_s.length
  end

  # Numero di cifre del divisore
  def divisor_length
    parsed_divisor.to_s.length
  end

  # Numero di cifre del quoziente (include extra zeros)
  def quotient_length
    extended_quotient.length
  end

  # Cifre del dividendo come array (interno, senza virgola)
  def dividend_digits
    parsed_dividend.to_s.chars
  end

  # Cifre del divisore come array (interno, senza virgola)
  def divisor_digits
    parsed_divisor.to_s.chars
  end

  # Cifre del quoziente come array (include extra zeros)
  def quotient_digits
    extended_quotient.chars
  end

  # Quoziente esteso calcolato con gli zeri extra
  def extended_quotient
    return @extended_quotient if @extended_quotient

    extended_dividend = parsed_dividend.to_s + ("0" * extra_zeros_count)
    result = ""
    partial = 0

    extended_dividend.each_char do |digit|
      partial = partial * 10 + digit.to_i
      q_digit = partial / parsed_divisor
      result += q_digit.to_s
      partial = partial - (q_digit * parsed_divisor)
    end

    @extended_quotient = result.sub(/^0+(?=\d)/, "")
  end

  # Cifre originali del dividendo (con info posizione virgola)
  def raw_dividend_digits
    raw_dividend.gsub(".", "").chars
  end

  # Cifre originali del divisore (con info posizione virgola)
  def raw_divisor_digits
    raw_divisor.gsub(".", "").chars
  end

  # Calcola i passi della divisione in colonna
  def division_steps
    steps = []
    dividend_str = parsed_dividend.to_s
    extended_dividend = dividend_str + ("0" * extra_zeros_count)
    partial_dividend = 0
    quotient_str = ""

    extended_dividend.each_char.with_index do |digit, idx|
      partial_dividend = partial_dividend * 10 + digit.to_i
      q_digit = partial_dividend / parsed_divisor
      quotient_str += q_digit.to_s
      product = q_digit * parsed_divisor
      remainder_val = partial_dividend - product
      next_idx = idx + 1
      bring_down = next_idx < extended_dividend.length ? extended_dividend[next_idx] : nil

      steps << {
        step_index: idx,
        partial_dividend: partial_dividend,
        quotient_digit: q_digit,
        product: product,
        remainder: remainder_val,
        bring_down: bring_down,
        is_extra_zero: idx >= dividend_str.length
      }

      partial_dividend = remainder_val
    end

    steps
  end

  # Numero massimo di righe per i calcoli intermedi
  def max_calculation_rows
    dividend_length * 2
  end

  # Larghezza della colonna sinistra (dividendo e calcoli)
  def left_column_width
    [ dividend_length, (quotient * parsed_divisor).to_s.length ].max + 1
  end

  # Larghezza della colonna destra (divisore e quoziente)
  def right_column_width
    [ divisor_length, quotient_length ].max
  end

  # Verifica se la divisione ha resto
  def has_remainder?
    remainder > 0
  end

  # Verifica se è una divisione esatta
  def exact?
    remainder.zero?
  end

  # Stringa per display
  def to_s
    if has_remainder?
      "#{parsed_dividend} : #{parsed_divisor} = #{quotient} resto #{remainder}"
    else
      "#{parsed_dividend} : #{parsed_divisor} = #{quotient}"
    end
  end

  # Reset dei valori calcolati
  def reset_calculations!
    @raw_dividend = nil
    @raw_divisor = nil
    @dividend_decimals = nil
    @divisor_decimals = nil
    @decimal_shift = nil
    @parsed_dividend = nil
    @parsed_divisor = nil
    @quotient = nil
    @remainder = nil
    @extended_quotient = nil
  end
end
