# frozen_string_literal: true

# Modello per rappresentare un'operazione in colonna (addizione o sottrazione)
class Addizione
  attr_reader :addends, :operator, :result, :max_digits,
              :title, :show_exercise, :show_addends, :show_solution, :show_toolbar, :show_carry,
              :show_addend_indices

  def initialize(addends:, operator: "+", **options)
    @addends = addends
    @operator = operator
    @result = calculate_result
    @max_digits = [ @addends.max, @result ].compact.max.to_s.length

    # Opzioni di visualizzazione
    @title = options[:title]
    @show_exercise = options.fetch(:show_exercise, true)
    @show_addends = options.fetch(:show_addends, false)
    @show_solution = options.fetch(:show_solution, false)
    @show_toolbar = options.fetch(:show_toolbar, false)
    @show_carry = options.fetch(:show_carry, true)
    # Array di indici degli addendi da mostrare (es: [0] per mostrare solo il primo)
    # Se nil, usa show_addends per tutti
    @show_addend_indices = options[:show_addend_indices]
  end

  # Verifica se un addendo specifico deve essere mostrato
  def show_addend?(index)
    if @show_addend_indices
      @show_addend_indices.include?(index)
    else
      @show_addends
    end
  end

  # Parsing di una stringa come "234 + 1234" o "500 - 123"
  def self.parse(operation_string)
    return nil if operation_string.blank?

    # Rimuovi spazi e split per operatori
    parts = operation_string.gsub(/\s+/, "").split(/([+\-=])/)

    # Estrai numeri e operatore
    numbers = []
    operator = "+"

    parts.each do |part|
      if part.match?(/^\d+$/)
        numbers << part.to_i
      elsif part.match?(/^[+\-]$/)
        operator = part
      end
    end

    return nil if numbers.empty?

    new(addends: numbers, operator: operator)
  end

  # Parsing di più operazioni separate da virgola, punto e virgola o newline
  def self.parse_multiple(operations_string)
    return [] if operations_string.blank?

    operations_string
      .split(/[,;\n]/)
      .map(&:strip)
      .reject(&:blank?)
      .map { |op| parse(op) }
      .compact
  end

  # Calcola il risultato dell'operazione
  def calculate_result
    case @operator
    when "+"
      @addends.sum
    when "-"
      @addends[0] - @addends[1..-1].sum
    else
      @addends.sum
    end
  end

  # Calcola i riporti per ogni colonna (da destra a sinistra)
  def carries
    carries_array = Array.new(@max_digits, "")
    carry = 0

    (@max_digits - 1).downto(0) do |col_idx|
      # Somma tutti i digit di questa colonna
      column_sum = carry
      addends_digits.each do |digits|
        digit_val = digits[col_idx].to_i
        column_sum += digit_val
      end

      # Se la somma è >= 10, c'è un riporto
      if column_sum >= 10
        carry = column_sum / 10
        # Il riporto va nella colonna precedente (a sinistra)
        carries_array[col_idx - 1] = carry.to_s if col_idx > 0
      else
        carry = 0
      end
    end

    carries_array
  end

  # Converti ogni addendo in array di cifre (da sinistra a destra)
  # Gli zeri non significativi vengono sostituiti con stringhe vuote
  def addends_digits
    @addends.map do |num|
      num_str = num.to_s
      padding = @max_digits - num_str.length
      # Crea array con celle vuote per gli zeri non significativi
      ([ "" ] * padding) + num_str.chars
    end
  end

  # Array di cifre del risultato
  def result_digits
    result_str = @result.to_s
    result_padding = @max_digits - result_str.length
    ([ "" ] * result_padding) + result_str.chars
  end

  # Etichette delle colonne (da sinistra a destra: più significativo a meno significativo)
  def column_labels
    labels = []

    labels << "M" if @max_digits >= 7    # Milioni
    labels << "hk" if @max_digits >= 6   # Centinaia di migliaia
    labels << "dak" if @max_digits >= 5  # Decine di migliaia
    labels << "uk" if @max_digits >= 4   # Unità di migliaia
    labels << "h" if @max_digits >= 3    # Centinaia
    labels << "da" if @max_digits >= 2   # Decine
    labels << "u"                         # Unità (sempre presente)

    # Padding per avere sempre max_digits etichette
    while labels.length < @max_digits
      labels.unshift("")
    end

    labels
  end

  # Colori per le etichette delle colonne
  def column_colors
    colors = []

    colors << "text-purple-600" if @max_digits >= 7
    colors << "text-orange-600" if @max_digits >= 6
    colors << "text-yellow-600" if @max_digits >= 5
    colors << "text-pink-600" if @max_digits >= 4
    colors << "text-green-600" if @max_digits >= 3
    colors << "text-red-500" if @max_digits >= 2
    colors << "text-blue-600"

    while colors.length < @max_digits
      colors.unshift("text-gray-400")
    end

    colors
  end

  # Stile CSS per il grid
  def grid_style
    "display: grid; grid-template-columns: repeat(#{@max_digits}, 4rem); gap: 0;"
  end

  # Parametri da passare al partial - semplicemente l'oggetto stesso
  def to_partial_params
    { addizione: self }
  end

  # Stringa per display (es: "234 + 1234")
  def to_s
    @addends.join(" #{@operator} ")
  end
end
