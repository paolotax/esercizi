# frozen_string_literal: true

require "bigdecimal"

# Modello per rappresentare una divisione in colonna (metodo italiano)
# Supporta divisioni con resto e calcolo passo-passo
# Supporta numeri decimali con virgola spostabile
#
# Layout divisione italiana:
#   dividendo | divisore
#   ----------|----------
#             | quoziente
#   resti...  |
#
class Divisione
  attr_reader :dividend, :divisor, :quotient, :remainder,
              :show_dividend_divisor, :show_toolbar, :show_solution, :show_steps,
              :title, :raw_dividend, :raw_divisor,
              :dividend_decimals, :divisor_decimals, :decimal_shift,
              :extra_zeros

  def initialize(dividend:, divisor:, **options)
    # Salva le stringhe originali con virgola
    @raw_dividend = normalize_number_string(dividend)
    @raw_divisor = normalize_number_string(divisor)

    # Conta i decimali originali
    @dividend_decimals = count_decimals(@raw_dividend)
    @divisor_decimals = count_decimals(@raw_divisor)

    # Calcola lo shift decimale (quante posizioni spostare la virgola)
    # Per rendere il divisore intero, dobbiamo spostare entrambi dello stesso numero di posizioni
    @decimal_shift = @divisor_decimals

    # Per il calcolo interno, convertiamo a interi spostando la virgola
    # Es: 12,5 : 2,5 diventa 125 : 25
    @dividend = to_integer_shifted(@raw_dividend, @decimal_shift)
    @divisor = to_integer_shifted(@raw_divisor, @decimal_shift)

    raise ArgumentError, "Il divisore non può essere zero" if @divisor.zero?

    @quotient = @dividend / @divisor
    @remainder = @dividend % @divisor

    # Numero di zeri extra per continuare la divisione (configurabile)
    @extra_zeros = options.fetch(:extra_zeros, 0)

    # Opzioni di visualizzazione
    @title = options[:title]
    @show_dividend_divisor = options.fetch(:show_dividend_divisor, true)
    @show_toolbar = options.fetch(:show_toolbar, true)
    @show_solution = options.fetch(:show_solution, false)
    @show_steps = options.fetch(:show_steps, false)
  end

  # Normalizza una stringa numerica: accetta virgola o punto come separatore
  def normalize_number_string(value)
    return value.to_s if value.is_a?(Integer)
    str = value.to_s.strip
    str.gsub(",", ".")
  end

  # Conta le cifre decimali di una stringa numerica
  def count_decimals(str)
    if str.include?(".")
      str.split(".").last.length
    else
      0
    end
  end

  # Converte un numero decimale in intero spostando la virgola
  # Es: "12.5" con shift=1 diventa 125
  # Es: "12.5" con shift=2 diventa 1250
  def to_integer_shifted(str, shift)
    decimals = count_decimals(str)
    # Rimuovi il punto
    digits_only = str.gsub(".", "")
    # Se lo shift è maggiore dei decimali esistenti, aggiungi zeri
    zeros_to_add = shift - decimals
    if zeros_to_add > 0
      digits_only += "0" * zeros_to_add
    end
    digits_only.to_i
  end

  # Verifica se l'operazione ha decimali
  def has_decimals?
    @dividend_decimals > 0 || @divisor_decimals > 0
  end

  # Posizione della virgola nel quoziente (da destra)
  # Dipende da quanti decimali ha il dividendo dopo lo shift + gli zeri extra
  def quotient_decimal_position
    # Se il dividendo originale ha più decimali del divisore, il quoziente avrà decimali
    extra_dividend_decimals = @dividend_decimals - @divisor_decimals
    # Aggiungi gli zeri extra che abbiamo aggiunto al dividendo
    base_decimals = extra_dividend_decimals > 0 ? extra_dividend_decimals : 0
    base_decimals + @extra_zeros
  end

  # Numero di cifre del dividendo
  def dividend_length
    @dividend.to_s.length
  end

  # Numero di cifre del divisore
  def divisor_length
    @divisor.to_s.length
  end

  # Numero di cifre del quoziente (include extra zeros)
  def quotient_length
    extended_quotient.length
  end

  # Cifre del dividendo come array (interno, senza virgola)
  def dividend_digits
    @dividend.to_s.chars
  end

  # Cifre del divisore come array (interno, senza virgola)
  def divisor_digits
    @divisor.to_s.chars
  end

  # Cifre del quoziente come array (include extra zeros)
  def quotient_digits
    extended_quotient.chars
  end

  # Quoziente esteso calcolato con gli zeri extra
  def extended_quotient
    return @extended_quotient if @extended_quotient

    extended_dividend = @dividend.to_s + ("0" * @extra_zeros)
    result = ""
    partial = 0

    extended_dividend.each_char do |digit|
      partial = partial * 10 + digit.to_i
      q_digit = partial / @divisor
      result += q_digit.to_s
      partial = partial - (q_digit * @divisor)
    end

    # Rimuovi zeri iniziali (ma lascia almeno una cifra)
    @extended_quotient = result.sub(/^0+(?=\d)/, "")
  end

  # Cifre originali del dividendo (con info posizione virgola)
  def raw_dividend_digits
    @raw_dividend.gsub(".", "").chars
  end

  # Cifre originali del divisore (con info posizione virgola)
  def raw_divisor_digits
    @raw_divisor.gsub(".", "").chars
  end

  # Calcola i passi della divisione in colonna
  # Restituisce un array di hash con:
  #   - partial_dividend: il dividendo parziale in quel passo
  #   - quotient_digit: la cifra del quoziente
  #   - product: il prodotto (divisore × cifra quoziente)
  #   - remainder: il resto parziale
  #   - bring_down: la cifra abbassata (se presente)
  #   - is_extra_zero: true se questa cifra è uno zero aggiunto
  def division_steps
    steps = []
    dividend_str = @dividend.to_s
    # Aggiungi gli zeri extra al dividendo per continuare la divisione
    extended_dividend = dividend_str + ("0" * @extra_zeros)
    partial_dividend = 0
    quotient_str = ""

    extended_dividend.each_char.with_index do |digit, idx|
      # Abbassa la cifra
      partial_dividend = partial_dividend * 10 + digit.to_i

      # Calcola la cifra del quoziente
      q_digit = partial_dividend / @divisor
      quotient_str += q_digit.to_s

      # Calcola il prodotto e il resto
      product = q_digit * @divisor
      remainder = partial_dividend - product

      # Determina la prossima cifra da abbassare
      next_idx = idx + 1
      bring_down = next_idx < extended_dividend.length ? extended_dividend[next_idx] : nil

      steps << {
        step_index: idx,
        partial_dividend: partial_dividend,
        quotient_digit: q_digit,
        product: product,
        remainder: remainder,
        bring_down: bring_down,
        is_extra_zero: idx >= dividend_str.length
      }

      partial_dividend = remainder
    end

    steps
  end

  # Numero massimo di righe per i calcoli intermedi
  # (ogni passo può generare fino a 2 righe: prodotto e resto)
  def max_calculation_rows
    dividend_length * 2
  end

  # Larghezza della colonna sinistra (dividendo e calcoli)
  def left_column_width
    # Il dividendo determina la larghezza base
    # Aggiungiamo 1 per eventuali resti che possono essere più larghi
    [ dividend_length, (@quotient * @divisor).to_s.length ].max + 1
  end

  # Larghezza della colonna destra (divisore e quoziente)
  def right_column_width
    [ divisor_length, quotient_length ].max
  end

  # Parsing di una stringa come "144 : 12" o "144/12" o "12,5 : 2,5"
  def self.parse(operation_string)
    return nil if operation_string.blank?

    # Supporta : / ÷ come operatori
    parts = operation_string.gsub(/\s+/, "").split(/[:\÷\/]/)

    return nil if parts.length < 2

    dividend = parts[0]
    divisor = parts[1]

    # Verifica che i numeri siano validi (possono avere virgola o punto)
    return nil unless dividend.match?(/^\d+([.,]\d+)?$/)
    return nil unless divisor.match?(/^\d+([.,]\d+)?$/)
    return nil if divisor.gsub(/[.,]/, "").to_i.zero?

    new(dividend: dividend, divisor: divisor)
  end

  # Parsing di più operazioni
  def self.parse_multiple(operations_string)
    return [] if operations_string.blank?

    operations_string
      .split(/[;\n]/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |op| parse(op) }
      .compact
  end

  # Verifica se la divisione ha resto
  def has_remainder?
    @remainder > 0
  end

  # Verifica se è una divisione esatta
  def exact?
    @remainder.zero?
  end

  # Stringa per display
  def to_s
    if has_remainder?
      "#{@dividend} : #{@divisor} = #{@quotient} resto #{@remainder}"
    else
      "#{@dividend} : #{@divisor} = #{@quotient}"
    end
  end

  # Parametri da passare al partial
  def to_partial_params
    { divisione: self }
  end
end
