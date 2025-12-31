# frozen_string_literal: true

require "bigdecimal"

# Logica di calcolo per moltiplicazioni
# Può essere usato sia dal model AR che dal Renderer
module Moltiplicazione::Calculation
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

  # Converte stringa in numero (Integer o BigDecimal per precisione)
  def parse_to_number(str)
    str.include?(".") ? BigDecimal(str) : str.to_i
  end

  # Moltiplicando normalizzato come stringa
  def raw_multiplicand
    @raw_multiplicand ||= normalize_number_string(multiplicand)
  end

  # Moltiplicatore normalizzato come stringa
  def raw_multiplier
    @raw_multiplier ||= normalize_number_string(multiplier)
  end

  # Decimali nel moltiplicando
  def multiplicand_decimals
    @multiplicand_decimals ||= count_decimals(raw_multiplicand)
  end

  # Decimali nel moltiplicatore
  def multiplier_decimals
    @multiplier_decimals ||= count_decimals(raw_multiplier)
  end

  # Totale cifre decimali nel prodotto
  def decimal_places
    @decimal_places ||= multiplicand_decimals + multiplier_decimals
  end

  # Moltiplicando come numero
  def parsed_multiplicand
    @parsed_multiplicand ||= parse_to_number(raw_multiplicand)
  end

  # Moltiplicatore come numero
  def parsed_multiplier
    @parsed_multiplier ||= parse_to_number(raw_multiplier)
  end

  # Prodotto finale
  def product
    @product ||= parsed_multiplicand * parsed_multiplier
  end

  # Alias per compatibilità
  def result
    product
  end

  # Verifica se l'operazione ha decimali
  def has_decimals?
    decimal_places > 0
  end

  # Calcola il numero massimo di cifre intere nel risultato
  def max_integer_digits
    @max_integer_digits ||= product.abs.to_i.to_s.length
  end

  # Numero massimo di cifre per il quaderno (include decimali)
  def max_digits
    max_integer_digits + decimal_places
  end

  # Numero totale di colonne per le cifre (senza colonna virgola separata)
  def total_digit_columns
    max_digits
  end

  # Posizione della virgola nel risultato (da destra, 0-indexed)
  def comma_position_from_right
    decimal_places
  end

  # Lunghezza delle cifre del moltiplicando (senza virgola)
  def multiplicand_length
    raw_multiplicand.gsub(".", "").length
  end

  # Lunghezza delle cifre del moltiplicatore (senza virgola)
  def multiplier_length
    raw_multiplier.gsub(".", "").length
  end

  # Lunghezza delle cifre del prodotto
  def product_length
    if has_decimals?
      format("%.#{decimal_places}f", product).gsub(".", "").length
    else
      product.to_s.length
    end
  end

  # Cifre del moltiplicando come array di interi (per calcoli interni)
  def multiplicand_digits
    raw_multiplicand.gsub(".", "").chars.map(&:to_i)
  end

  # Cifre del moltiplicatore come array di interi (per calcoli interni)
  def multiplier_digits
    raw_multiplier.gsub(".", "").chars.map(&:to_i)
  end

  # Cifre del risultato come array
  def result_digits_array
    if has_decimals?
      format("%.#{decimal_places}f", product).gsub(".", "").chars.map(&:to_i)
    else
      product.to_s.chars.map(&:to_i)
    end
  end

  # Dati per i prodotti parziali
  def partial_products_data
    return [] unless multiplier_length > 1

    multiplier_digits.reverse.each_with_index.map do |digit, row_index|
      multiplicand_int = raw_multiplicand.gsub(".", "").to_i
      partial_product = multiplicand_int * digit
      partial_str = partial_product.to_s

      num_inputs = product_length - row_index
      num_carries = num_inputs - 1

      digits = partial_str.chars.map(&:to_i)
      padded_digits = Array.new(num_inputs - digits.length, nil) + digits

      carries = calculate_partial_carries(digit)
      padded_carries = Array.new(num_carries - carries.length, nil) + carries.reverse

      {
        digits: padded_digits,
        carries: padded_carries,
        num_inputs: num_inputs,
        num_carries: num_carries,
        row_index: row_index
      }
    end
  end

  # Calcola i riporti per un prodotto parziale
  # Restituisce array ordinato da sinistra a destra (prima colonna = indice 0)
  def calculate_partial_carries(multiplier_digit)
    multiplicand_int = raw_multiplicand.gsub(".", "").to_i
    multiplicand_reversed = multiplicand_int.to_s.chars.reverse.map(&:to_i)
    carry = 0
    carries = []

    multiplicand_reversed.each do |d|
      product_val = d * multiplier_digit + carry
      carry = product_val / 10
      carries << (carry > 0 ? carry : nil)
    end

    # Rimuove l'ultimo (non c'è colonna per quel riporto) e inverte per ordine sx→dx
    carries.pop
    carries.reverse
  end

  # Riporti per il risultato finale
  def result_carries
    if multiplier_length > 1
      calculate_sum_carries
    else
      calculate_direct_multiplication_carries
    end
  end

  # Calcola i riporti dalla moltiplicazione diretta (moltiplicatore a 1 cifra)
  # I riporti vanno sopra la colonna della cifra che li RICEVE (a sinistra di quella che li genera)
  def calculate_direct_multiplication_carries
    multiplicand_int = raw_multiplicand.gsub(".", "").to_i
    multiplier_int = raw_multiplier.gsub(".", "").to_i
    multiplicand_reversed = multiplicand_int.to_s.chars.reverse.map(&:to_i)
    num_carries = product_length - 1
    carries = Array.new(num_carries, nil)
    carry = 0

    multiplicand_reversed.each_with_index do |d, i|
      partial_result = d * multiplier_int + carry
      carry = partial_result / 10
      # Il riporto va sopra la colonna i+1 (la prossima cifra a sinistra)
      # target_index conta da sinistra: 0 è la prima colonna, num_carries-1 è l'ultima
      # i=0 (unità) genera riporto per decine → target_index = num_carries-1-i
      if carry > 0 && i < multiplicand_reversed.length - 1
        target_index = num_carries - 1 - i
        carries[target_index] = carry if target_index >= 0
      end
    end

    carries
  end

  # Calcola i riporti dalla somma dei prodotti parziali
  def calculate_sum_carries
    multiplier_reversed = multiplier_digits.reverse
    num_carries = product_length - 1
    carries = Array.new(num_carries, nil)
    carry = 0

    product_length.times do |col|
      sum = carry

      multiplier_reversed.each_with_index do |digit, row_index|
        multiplicand_int = raw_multiplicand.gsub(".", "").to_i
        partial = multiplicand_int * digit
        partial_str = partial.to_s.reverse
        col_in_partial = col - row_index

        if col_in_partial >= 0 && col_in_partial < partial_str.length
          sum += partial_str[col_in_partial].to_i
        end
      end

      carry = sum / 10
      if carry > 0 && col < product_length - 1
        target_index = num_carries - 1 - col
        carries[target_index] = carry if target_index >= 0
      end
    end

    carries
  end

  # Reset dei valori calcolati (da chiamare quando cambiano i dati)
  def reset_calculations!
    @raw_multiplicand = nil
    @raw_multiplier = nil
    @multiplicand_decimals = nil
    @multiplier_decimals = nil
    @decimal_places = nil
    @parsed_multiplicand = nil
    @parsed_multiplier = nil
    @product = nil
    @max_integer_digits = nil
  end
end
