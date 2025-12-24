# frozen_string_literal: true

require "bigdecimal"

# Logica di calcolo per addizioni
# Può essere usato sia dal model AR che dal Renderer
module Addizione::Calculation
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

  # Array di addendi normalizzati come stringhe
  def raw_addends
    @raw_addends ||= Array(addends).map { |a| normalize_number_string(a) }
  end

  # Array di addendi come numeri
  def parsed_addends
    @parsed_addends ||= raw_addends.map { |s| parse_to_number(s) }
  end

  # Calcola il numero massimo di cifre decimali tra tutti gli addendi
  def decimal_places
    @decimal_places ||= raw_addends.map do |str|
      str.include?(".") ? str.split(".").last.length : 0
    end.max || 0
  end

  # Verifica se l'operazione ha decimali
  def has_decimals?
    decimal_places > 0
  end

  # Calcola il numero massimo di cifre intere
  def max_integer_digits
    @max_integer_digits ||= begin
      all_numbers = parsed_addends + [ result ]
      all_numbers.map { |n| n.abs.to_i.to_s.length }.max
    end
  end

  # Alias per compatibilità
  def max_digits
    max_integer_digits
  end

  # Calcola il risultato dell'operazione
  def result
    @result ||= case current_operator
    when "+"
                  parsed_addends.sum
    when "-"
                  parsed_addends[0] - parsed_addends[1..-1].sum
    else
                  parsed_addends.sum
    end
  end

  # Operatore corrente (default +)
  def current_operator
    respond_to?(:operator) ? (operator || "+") : "+"
  end

  # Converti ogni addendo in array di cifre (da sinistra a destra)
  # Gli zeri non significativi vengono sostituiti con stringhe vuote
  def addends_digits
    @addends_digits ||= parsed_addends.map do |num|
      num_str = num.to_s
      padding = max_digits - num_str.length
      ([ "" ] * padding) + num_str.chars
    end
  end

  # Array di cifre del risultato
  def result_digits
    @result_digits ||= begin
      result_str = result.to_s
      result_padding = max_digits - result_str.length
      ([ "" ] * result_padding) + result_str.chars
    end
  end

  # Calcola i riporti per ogni colonna (da destra a sinistra)
  def carries
    @carries ||= begin
      carries_array = Array.new(max_digits, "")
      carry = 0

      (max_digits - 1).downto(0) do |col_idx|
        column_sum = carry
        addends_digits.each do |digits|
          digit_val = digits[col_idx].to_i
          column_sum += digit_val
        end

        if column_sum >= 10
          carry = column_sum / 10
          carries_array[col_idx - 1] = carry.to_s if col_idx > 0
        else
          carry = 0
        end
      end

      carries_array
    end
  end

  # Reset dei valori calcolati (da chiamare quando cambiano i dati)
  def reset_calculations!
    @raw_addends = nil
    @parsed_addends = nil
    @decimal_places = nil
    @max_integer_digits = nil
    @result = nil
    @addends_digits = nil
    @result_digits = nil
    @carries = nil
  end
end
