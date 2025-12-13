# frozen_string_literal: true

# Modello per rappresentare una divisione in colonna (metodo italiano)
# Supporta divisioni con resto e calcolo passo-passo
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
              :title

  def initialize(dividend:, divisor:, **options)
    @dividend = dividend.to_i
    @divisor = divisor.to_i

    raise ArgumentError, "Il divisore non può essere zero" if @divisor.zero?

    @quotient = @dividend / @divisor
    @remainder = @dividend % @divisor

    # Opzioni di visualizzazione
    @title = options[:title]
    @show_dividend_divisor = options.fetch(:show_dividend_divisor, true)
    @show_toolbar = options.fetch(:show_toolbar, true)
    @show_solution = options.fetch(:show_solution, false)
    @show_steps = options.fetch(:show_steps, false)
  end

  # Numero di cifre del dividendo
  def dividend_length
    @dividend.to_s.length
  end

  # Numero di cifre del divisore
  def divisor_length
    @divisor.to_s.length
  end

  # Numero di cifre del quoziente
  def quotient_length
    @quotient.to_s.length
  end

  # Cifre del dividendo come array
  def dividend_digits
    @dividend.to_s.chars
  end

  # Cifre del divisore come array
  def divisor_digits
    @divisor.to_s.chars
  end

  # Cifre del quoziente come array
  def quotient_digits
    @quotient.to_s.chars
  end

  # Calcola i passi della divisione in colonna
  # Restituisce un array di hash con:
  #   - partial_dividend: il dividendo parziale in quel passo
  #   - quotient_digit: la cifra del quoziente
  #   - product: il prodotto (divisore × cifra quoziente)
  #   - remainder: il resto parziale
  #   - bring_down: la cifra abbassata (se presente)
  def division_steps
    steps = []
    dividend_str = @dividend.to_s
    partial_dividend = 0
    quotient_str = ""

    dividend_str.each_char.with_index do |digit, idx|
      # Abbassa la cifra
      partial_dividend = partial_dividend * 10 + digit.to_i

      # Calcola la cifra del quoziente
      q_digit = partial_dividend / @divisor
      quotient_str += q_digit.to_s

      # Calcola il prodotto e il resto
      product = q_digit * @divisor
      remainder = partial_dividend - product

      steps << {
        step_index: idx,
        partial_dividend: partial_dividend,
        quotient_digit: q_digit,
        product: product,
        remainder: remainder,
        bring_down: idx < dividend_str.length - 1 ? dividend_str[idx + 1] : nil
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

  # Parsing di una stringa come "144 : 12" o "144/12"
  def self.parse(operation_string)
    return nil if operation_string.blank?

    # Supporta : / ÷ come operatori
    parts = operation_string.gsub(/\s+/, "").split(/[:\÷\/]/)

    return nil if parts.length < 2

    dividend = parts[0].to_i
    divisor = parts[1].to_i

    return nil if divisor.zero?

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
