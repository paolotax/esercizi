# frozen_string_literal: true

# Helper per semplificare il rendering delle operazioni matematiche nelle pagine esercizi
#
# Esempi d'uso:
#
#   # Addizione semplice
#   <%= addizione_grid [152, 235], show_addends: true, show_labels: true %>
#
#   # Addizione da stringa
#   <%= addizione_grid "152 + 235", show_addends: true %>
#
#   # Sottrazione
#   <%= sottrazione_grid 398, 145, show_minuend_subtrahend: true, show_labels: true %>
#
#   # Moltiplicazione
#   <%= moltiplicazione_grid 123, 45, show_multiplicand_multiplier: true %>
#
#   # Divisione
#   <%= divisione_grid 144, 12, show_dividend_divisor: true %>
#
module OperazioniHelper
  # Renderizza una griglia addizione
  #
  # @param addends_or_string [Array, String] Array di addendi o stringa "12 + 34"
  # @param options [Hash] Opzioni per il renderer
  # @option options [Boolean] :show_addends Mostra gli addendi (default: false)
  # @option options [Boolean] :show_solution Mostra il risultato (default: false)
  # @option options [Boolean] :show_carry Mostra i riporti (default: false)
  # @option options [Boolean] :show_toolbar Mostra la toolbar (default: false)
  # @option options [Boolean] :show_labels Mostra le etichette u/da/h/k (default: false)
  # @option options [Symbol] :style :quaderno o :column (default: :quaderno)
  # @option options [Symbol] :grid_style Alias per :style
  # @option options [String] :title Titolo opzionale
  #
  def addizione_grid(addends_or_string, **options)
    addends = parse_addends(addends_or_string)
    return "" if addends.blank?

    grid_style = options[:grid_style] || options.fetch(:style, :quaderno)

    renderer = Addizione::Renderer.new(
      addends: addends,
      show_addends: options.fetch(:show_addends, false),
      show_solution: options.fetch(:show_solution, false),
      show_carry: options.fetch(:show_carry, false),
      show_toolbar: options.fetch(:show_toolbar, false),
      show_labels: options.fetch(:show_labels, false),
      grid_style: grid_style,
      title: options[:title]
    )

    render "strumenti/addizioni/addizione_grid", grid: renderer.to_grid_matrix
  end

  # Renderizza una griglia sottrazione
  #
  # @param minuend [Integer, String] Minuendo
  # @param subtrahend [Integer, String] Sottraendo
  # @param options [Hash] Opzioni per il renderer
  # @option options [Boolean] :show_minuend_subtrahend Mostra minuendo e sottraendo (default: false)
  # @option options [Boolean] :show_solution Mostra il risultato (default: false)
  # @option options [Boolean] :show_borrow Mostra i prestiti (default: false)
  # @option options [Boolean] :show_toolbar Mostra la toolbar (default: false)
  # @option options [Boolean] :show_labels Mostra le etichette u/da/h/k (default: false)
  # @option options [Symbol] :style :quaderno o :column (default: :quaderno)
  # @option options [Symbol] :grid_style Alias per :style
  # @option options [String] :title Titolo opzionale
  #
  def sottrazione_grid(minuend, subtrahend, **options)
    grid_style = options[:grid_style] || options.fetch(:style, :quaderno)

    renderer = Sottrazione::Renderer.new(
      minuend: minuend,
      subtrahend: subtrahend,
      show_minuend_subtrahend: options.fetch(:show_minuend_subtrahend, false),
      show_solution: options.fetch(:show_solution, false),
      show_borrow: options.fetch(:show_borrow, false),
      show_toolbar: options.fetch(:show_toolbar, false),
      show_labels: options.fetch(:show_labels, false),
      grid_style: grid_style,
      title: options[:title]
    )

    render "strumenti/sottrazioni/sottrazione_grid", grid: renderer.to_grid_matrix
  end

  # Renderizza una griglia moltiplicazione
  #
  # @param multiplicand [Integer, String] Moltiplicando
  # @param multiplier [Integer, String] Moltiplicatore
  # @param options [Hash] Opzioni per il renderer
  # @option options [Boolean] :show_multiplicand_multiplier Mostra moltiplicando e moltiplicatore (default: false)
  # @option options [Boolean] :show_solution Mostra il risultato (default: false)
  # @option options [Boolean] :show_partial_products Mostra i prodotti parziali (default: false)
  # @option options [Boolean] :show_carry Mostra i riporti (default: false)
  # @option options [Boolean] :show_toolbar Mostra la toolbar (default: false)
  # @option options [Boolean] :show_labels Mostra le etichette (default: false)
  # @option options [Symbol] :style :quaderno o :column (default: :quaderno)
  # @option options [Symbol] :grid_style Alias per :style
  # @option options [String] :title Titolo opzionale
  #
  def moltiplicazione_grid(multiplicand, multiplier, **options)
    grid_style = options[:grid_style] || options.fetch(:style, :quaderno)

    renderer = Moltiplicazione::Renderer.new(
      multiplicand: multiplicand,
      multiplier: multiplier,
      show_multiplicand_multiplier: options.fetch(:show_multiplicand_multiplier, false),
      show_solution: options.fetch(:show_solution, false),
      show_partial_products: options.fetch(:show_partial_products, false),
      show_carry: options.fetch(:show_carry, false),
      show_toolbar: options.fetch(:show_toolbar, false),
      show_labels: options.fetch(:show_labels, false),
      grid_style: grid_style,
      title: options[:title]
    )

    render "strumenti/moltiplicazioni/moltiplicazione_grid", grid: renderer.to_grid_matrix
  end

  # Renderizza una griglia divisione
  #
  # @param dividend [Integer, String] Dividendo
  # @param divisor [Integer, String] Divisore
  # @param options [Hash] Opzioni per il renderer
  # @option options [Boolean] :show_dividend_divisor Mostra dividendo e divisore (default: false)
  # @option options [Boolean] :show_solution Mostra il risultato (default: false)
  # @option options [Boolean] :show_steps Mostra i passaggi (default: false)
  # @option options [Boolean] :show_toolbar Mostra la toolbar (default: false)
  # @option options [Symbol] :style :quaderno o :column (default: :quaderno)
  # @option options [Symbol] :grid_style Alias per :style
  # @option options [String] :title Titolo opzionale
  #
  def divisione_grid(dividend, divisor, **options)
    grid_style = options[:grid_style] || options.fetch(:style, :quaderno)

    renderer = Divisione::Renderer.new(
      dividend: dividend,
      divisor: divisor,
      show_dividend_divisor: options.fetch(:show_dividend_divisor, false),
      show_solution: options.fetch(:show_solution, false),
      show_steps: options.fetch(:show_steps, false),
      show_toolbar: options.fetch(:show_toolbar, false),
      grid_style: grid_style,
      title: options[:title]
    )

    render "strumenti/divisioni/divisione_grid", grid: renderer.to_grid_matrix
  end

  # Alias più corti per uso rapido
  alias_method :add_grid, :addizione_grid
  alias_method :sub_grid, :sottrazione_grid
  alias_method :mul_grid, :moltiplicazione_grid
  alias_method :div_grid, :divisione_grid

  # Renderizza una Question usando il renderer appropriato per il suo questionable type
  #
  # @param question [Question] Una Question con delegated_type :questionable
  # @param options [Hash] Opzioni per il renderer (sovrascrivono quelle del model)
  # @return [String] HTML renderizzato della griglia
  #
  # @example Uso base
  #   <%= question_grid(@question) %>
  #
  # @example Con opzioni
  #   <%= question_grid(@question, show_solution: true, show_labels: true) %>
  #
  def question_grid(question, **options)
    questionable = question.questionable
    return "" if questionable.blank?

    case questionable
    when Addizione
      data = questionable.data.with_indifferent_access
      addizione_grid(
        data[:addends] || [],
        show_addends: options.fetch(:show_addends, data[:show_addends]),
        show_solution: options.fetch(:show_solution, data[:show_solution]),
        show_carry: options.fetch(:show_carry, data[:show_carry]),
        show_toolbar: options.fetch(:show_toolbar, data[:show_toolbar]),
        show_labels: options.fetch(:show_labels, data[:show_labels]),
        style: options.fetch(:style, :quaderno),
        title: options[:title] || data[:title]
      )
    when Sottrazione
      data = questionable.data.with_indifferent_access
      sottrazione_grid(
        data[:minuend],
        data[:subtrahend],
        show_minuend_subtrahend: options.fetch(:show_minuend_subtrahend, data[:show_minuend_subtrahend]),
        show_solution: options.fetch(:show_solution, data[:show_solution]),
        show_borrow: options.fetch(:show_borrow, data[:show_borrow]),
        show_toolbar: options.fetch(:show_toolbar, data[:show_toolbar]),
        show_labels: options.fetch(:show_labels, data[:show_labels]),
        style: options.fetch(:style, :quaderno),
        title: options[:title] || data[:title]
      )
    when Moltiplicazione
      data = questionable.data.with_indifferent_access
      moltiplicazione_grid(
        data[:multiplicand],
        data[:multiplier],
        show_multiplicand_multiplier: options.fetch(:show_multiplicand_multiplier, data[:show_multiplicand_multiplier]),
        show_solution: options.fetch(:show_solution, data[:show_solution]),
        show_partial_products: options.fetch(:show_partial_products, data[:show_partial_products]),
        show_carry: options.fetch(:show_carry, data[:show_carry]),
        show_toolbar: options.fetch(:show_toolbar, data[:show_toolbar]),
        show_labels: options.fetch(:show_labels, data[:show_labels]),
        style: options.fetch(:style, :quaderno),
        title: options[:title] || data[:title]
      )
    when Divisione
      data = questionable.data.with_indifferent_access
      divisione_grid(
        data[:dividend],
        data[:divisor],
        show_dividend_divisor: options.fetch(:show_dividend_divisor, data[:show_dividend_divisor]),
        show_solution: options.fetch(:show_solution, data[:show_solution]),
        show_steps: options.fetch(:show_steps, data[:show_steps]),
        show_toolbar: options.fetch(:show_toolbar, data[:show_toolbar]),
        style: options.fetch(:style, :quaderno),
        title: options[:title] || data[:title]
      )
    when Abaco
      data = questionable.data.with_indifferent_access
      render "strumenti/abachi/abaco_grid", abaco: questionable.to_renderer.to_grid_data
    else
      ""
    end
  end

  # Mostra una rappresentazione testuale semplice di una Question
  #
  # @param question [Question] Una Question con delegated_type :questionable
  # @return [String] Rappresentazione testuale dell'operazione
  #
  # @example
  #   <%= question_display(@question) %> # => "152 + 235 = ?"
  #
  def question_display(question)
    questionable = question.questionable
    return "" if questionable.blank?

    data = questionable.data.with_indifferent_access rescue {}

    case questionable
    when Addizione
      (data[:addends] || []).join(" + ") + " = ?"
    when Sottrazione
      "#{data[:minuend]} − #{data[:subtrahend]} = ?"
    when Moltiplicazione
      "#{data[:multiplicand]} × #{data[:multiplier]} = ?"
    when Divisione
      "#{data[:dividend]} ÷ #{data[:divisor]} = ?"
    when Abaco
      "Valore: #{data[:correct_value] || data[:value] || '?'}"
    else
      questionable.class.name
    end
  end

  private

  # Converte input in array di addendi
  def parse_addends(addends_or_string)
    case addends_or_string
    when Array
      addends_or_string
    when String
      # Parse stringa tipo "12 + 34 + 56"
      addends_or_string.split(/\s*\+\s*/).map(&:strip).reject(&:blank?)
    else
      [addends_or_string]
    end
  end
end
