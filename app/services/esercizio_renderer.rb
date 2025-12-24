class EsercizioRenderer
  include ActionView::Helpers
  include ActionView::Context
  include Rails.application.routes.url_helpers

  def initialize(esercizio, view_context = nil)
    @esercizio = esercizio
    @view_context = view_context
  end

  def render
    return "" unless @esercizio.operations.any?

    html = []
    html << '<div class="esercizio-container grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">'

    @esercizio.operations.each do |operation|
      html << render_operation(operation)
    end

    html << "</div>"
    html.join("\n").html_safe
  end

  def render_operation(operation)
    case operation["type"]
    when "addizione"
      render_addizione(operation)
    when "sottrazione"
      render_sottrazione(operation)
    when "moltiplicazione"
      render_moltiplicazione(operation)
    when "abaco"
      render_abaco(operation)
    else
      render_unknown_operation(operation)
    end
  end

  private

  def render_addizione(operation)
    config = operation["config"] || {}

    # Usa SOLO i valori salvati dall'utente
    if config["operation_text"].present?
      # Parsa il testo per estrarre i numeri
      numbers = config["operation_text"].scan(/\d+/).map(&:to_i)
      addends = numbers.any? ? numbers : [ 0, 0 ]  # Default a 0 se non ci sono numeri
    elsif config["values"].present? && config["values"].any?
      # Usa i valori salvati
      addends = config["values"]
    else
      # Non generare numeri casuali - usa valori vuoti di default
      addends = [ 0, 0 ]
    end

    # Crea oggetto Addizione con opzioni corrette
    addizione = Addizione.new(
      addends: addends,
      operator: "+",
      show_toolbar: config["show_toolbar"] == true,
      show_exercise: true,
      show_solution: config["show_solution"] == true,
      show_carry: config["show_carry"] == true,
      show_addends: config["show_addends"] == true
    )

    # Prepara il titolo dell'operazione (usa il campo title se presente, altrimenti mostra operation_text)
    operation_title = config["title"].present? ? config["title"] : (config["operation_text"].present? ? config["operation_text"] : nil)

    html = []
    html << %Q(<div class="operation-container" data-operation-id="#{operation['id']}" data-operation-type="addizione">)

    if @view_context
      # Usa il partial esistente con il titolo e l'operation_id
      html << @view_context.render(
        partial: "strumenti/addizioni/column_addition",
        locals: {
          addizione: addizione,
          operation_title: operation_title,
          operation_id: operation["id"]
        }
      )
    else
      # Fallback HTML semplice
      html << %Q(<div class="p-4 border rounded">)
      html << %Q(<div class="text-center font-mono text-2xl">)
      addends.each_with_index do |addend, index|
        if index == 0
          html << %Q(<div>#{addend}</div>)
        elsif index == addends.length - 1
          html << %Q(<div class="border-b-2">+ #{addend}</div>)
        else
          html << %Q(<div>+ #{addend}</div>)
        end
      end
      html << %Q(<div class="mt-2">____</div>)
      html << %Q(</div>)
      html << %Q(</div>)
    end

    html << %Q(</div>)
    html.join("\n")
  end

  def render_sottrazione(operation)
    config = operation["config"] || {}

    # Usa SOLO i valori salvati dall'utente
    if config["operation_text"].present?
      # Parsa il testo per estrarre i numeri (es: "500 - 123")
      numbers = config["operation_text"].scan(/\d+/).map(&:to_i)
      minuend = numbers[0] || 0
      subtrahend = numbers[1] || 0
    elsif config["values"].present? && config["values"].any?
      minuend = config["values"][0] || 0
      subtrahend = config["values"][1] || 0
    else
      # Non generare numeri casuali - usa valori vuoti di default
      minuend = 0
      subtrahend = 0
    end

    # Crea oggetto Sottrazione corretto
    sottrazione = Sottrazione.new(
      minuend: minuend,
      subtrahend: subtrahend,
      show_toolbar: config["show_toolbar"] == true,
      show_exercise: true,
      show_solution: config["show_solution"] == true,
      show_minuend_subtrahend: config["show_addends"] == true,
      show_borrow: config["show_borrow"] == true
    )

    # Prepara il titolo dell'operazione (usa il campo title se presente, altrimenti mostra operation_text)
    operation_title = config["title"].present? ? config["title"] : (config["operation_text"].present? ? config["operation_text"] : nil)

    html = []
    html << %Q(<div class="operation-container" data-operation-id="#{operation['id']}" data-operation-type="sottrazione">)

    if @view_context
      # Usa il partial esistente con il titolo e l'operation_id
      html << @view_context.render(
        partial: "strumenti/sottrazioni/column_subtraction",
        locals: {
          sottrazione: sottrazione,
          operation_title: operation_title,
          operation_id: operation["id"]
        }
      )
    else
      # Fallback HTML semplice
      html << %Q(<div class="p-4 border rounded">)
      html << %Q(<div class="text-center font-mono text-2xl">)
      html << %Q(<div>#{minuend}</div>)
      html << %Q(<div class="border-b-2">- #{subtrahend}</div>)
      html << %Q(<div class="mt-2">____</div>)
      html << %Q(</div>)
      html << %Q(</div>)
    end

    html << %Q(</div>)
    html.join("\n")
  end

  def render_moltiplicazione(operation)
    config = operation["config"] || {}

    # Usa SOLO i valori salvati dall'utente
    if config["operation_text"].present?
      # Parsa il testo per estrarre i numeri (es: "12 x 5" o "12 × 5")
      numbers = config["operation_text"].scan(/\d+/).map(&:to_i)
      multiplicand = numbers[0] || 0
      multiplier = numbers[1] || 0
    elsif config["multiplicand"].present? && config["multiplier"].present?
      multiplicand = config["multiplicand"]
      multiplier = config["multiplier"]
    elsif config["values"].present? && config["values"].any?
      multiplicand = config["values"][0] || 0
      multiplier = config["values"][1] || 0
    else
      # Non generare numeri casuali - usa valori vuoti di default
      multiplicand = 0
      multiplier = 0
    end

    # Crea oggetto Moltiplicazione corretto
    moltiplicazione = Moltiplicazione::Renderer.new(
      multiplicand: multiplicand,
      multiplier: multiplier,
      show_multiplicand_multiplier: config["show_addends"] != false,
      show_toolbar: config["show_toolbar"] == true,
      show_partial_products: config["show_partial_products"] == true,
      show_solution: config["show_solution"] == true,
      editable: true,
      show_exercise: true
    )

    # Prepara il titolo dell'operazione (usa il campo title se presente, altrimenti mostra operation_text)
    operation_title = config["title"].present? ? config["title"] : (config["operation_text"].present? ? config["operation_text"] : nil)

    html = []
    html << %Q(<div class="operation-container" data-operation-id="#{operation['id']}" data-operation-type="moltiplicazione">)

    if @view_context
      # Usa il partial esistente con il titolo e l'operation_id
      html << @view_context.render(
        partial: "strumenti/moltiplicazioni/column_multiplication",
        locals: {
          moltiplicazione: moltiplicazione,
          operation_title: operation_title,
          operation_id: operation["id"]
        }
      )
    else
      # Fallback HTML semplice
      html << %Q(<div class="p-4 border rounded">)
      html << %Q(<div class="text-center font-mono text-2xl">)
      html << %Q(<div>#{multiplicand}</div>)
      html << %Q(<div class="border-b-2">× #{multiplier}</div>)
      html << %Q(<div class="mt-2">____</div>)
      html << %Q(</div>)
      html << %Q(</div>)
    end

    html << %Q(</div>)
    html.join("\n")
  end

  def render_abaco(operation)
    config = operation["config"] || {}

    # Usa SOLO i valori salvati dall'utente
    if config["operation_text"].present?
      # Parsa il testo per estrarre il numero
      value = config["operation_text"].scan(/\d+/).first&.to_i || 0
    elsif config["value"].present?
      value = config["value"]
    elsif config["values"].present? && config["values"].any?
      value = config["values"][0] || 0
    else
      # Non generare numeri casuali - usa valore vuoto di default
      value = 0
    end

    # Crea oggetto Abaco con parametri corretti
    abaco = Abaco::Renderer.new(
      number: value,
      editable: config["editable"] != false,
      show_value: config["show_value"] == true,
      max_per_column: (config["max_per_column"] || 9).to_i
    )

    # Prepara il titolo dell'operazione (usa il campo title se presente, altrimenti mostra operation_text)
    operation_title = config["title"].present? ? config["title"] : (config["operation_text"].present? ? config["operation_text"] : nil)

    html = []
    html << %Q(<div class="operation-container" data-operation-id="#{operation['id']}" data-operation-type="abaco">)

    if @view_context
      # Usa il partial esistente con il titolo e l'operation_id
      html << @view_context.render(
        partial: "strumenti/abaco/abaco",
        locals: {
          abaco: abaco,
          operation_title: operation_title,
          operation_id: operation["id"]
        }
      )
    else
      # Fallback HTML semplice
      html << %Q(<div class="p-4 border rounded">)
      html << %Q(<div class="text-center">)
      html << %Q(<p class="text-lg font-semibold mb-2">Abaco</p>)
      html << %Q(<div class="grid grid-cols-3 gap-2 mt-4">)

      # Mostra solo le colonne necessarie
      if value >= 100
        html << %Q(<div class="text-center">)
        html << %Q(<div class="text-xs text-gray-500 mb-1">C</div>)
        html << %Q(<div class="font-mono text-lg">#{value / 100}</div>)
        html << %Q(</div>)
      end

      if value >= 10
        html << %Q(<div class="text-center">)
        html << %Q(<div class="text-xs text-gray-500 mb-1">D</div>)
        html << %Q(<div class="font-mono text-lg">#{(value % 100) / 10}</div>)
        html << %Q(</div>)
      end

      html << %Q(<div class="text-center">)
      html << %Q(<div class="text-xs text-gray-500 mb-1">U</div>)
      html << %Q(<div class="font-mono text-lg">#{value % 10}</div>)
      html << %Q(</div>)

      html << %Q(</div>)
      html << %Q(</div>)
      html << %Q(</div>)
    end

    html << %Q(</div>)
    html.join("\n")
  end

  def render_unknown_operation(operation)
    %Q(
      <div class="operation-container bg-gray-100 p-4 rounded" data-operation-id="#{operation['id']}">
        <p class="text-gray-600">Tipo di operazione non riconosciuto: #{operation['type']}</p>
      </div>
    )
  end

  def render_operation_controls(operation)
    %Q(
      <div class="operation-controls float-right">
        <button class="edit-operation text-blue-600 hover:text-blue-800 mr-2"
                data-operation-id="#{operation['id']}">
          <svg class="w-4 h-4 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
          </svg>
        </button>
        <button class="remove-operation text-red-600 hover:text-red-800"
                data-operation-id="#{operation['id']}">
          <svg class="w-4 h-4 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
          </svg>
        </button>
      </div>
    )
  end

  def render_math_operation(operation_data)
    # Renderizza un'operazione matematica in formato colonna
    return "" unless operation_data

    %Q(
      <div class="math-operation font-mono text-2xl">
        <div class="operand">#{operation_data[:operand1]}</div>
        <div class="operand border-b-2 border-black">
          <span class="operator">#{operation_data[:operator]}</span>
          #{operation_data[:operand2]}
        </div>
        <div class="result mt-2">
          <input type="text" class="result-input w-full border-b-2 border-gray-400
                                     focus:border-blue-500 outline-none text-center"
                 data-correct-answer="#{operation_data[:result]}"
                 placeholder="?">
        </div>
      </div>
    )
  end

  def render_abaco_visual(abaco_data)
    # Renderizza una rappresentazione visuale dell'abaco
    return "" unless abaco_data

    %Q(
      <div class="abaco-visual">
        <div class="abaco-display grid grid-cols-3 gap-2">
          <div class="centinaia text-center">
            <div class="font-semibold text-sm">Centinaia</div>
            <div class="beads">#{render_beads(abaco_data[:centinaia])}</div>
          </div>
          <div class="decine text-center">
            <div class="font-semibold text-sm">Decine</div>
            <div class="beads">#{render_beads(abaco_data[:decine])}</div>
          </div>
          <div class="unita text-center">
            <div class="font-semibold text-sm">Unità</div>
            <div class="beads">#{render_beads(abaco_data[:unita])}</div>
          </div>
        </div>
        <div class="mt-4">
          <input type="text" class="result-input w-full border p-2 rounded"
                 data-correct-answer="#{abaco_data[:value]}"
                 placeholder="Inserisci il numero">
        </div>
      </div>
    )
  end

  def render_beads(count)
    beads = []
    count.to_i.times do
      beads << '<span class="inline-block w-3 h-3 bg-blue-500 rounded-full m-1"></span>'
    end
    beads.join
  end
end
