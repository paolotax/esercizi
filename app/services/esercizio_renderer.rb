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

    html << '</div>'
    html.join("\n").html_safe
  end

  def render_operation(operation)
    case operation['type']
    when 'addizione'
      render_addizione(operation)
    when 'sottrazione'
      render_sottrazione(operation)
    when 'moltiplicazione'
      render_moltiplicazione(operation)
    when 'abaco'
      render_abaco(operation)
    else
      render_unknown_operation(operation)
    end
  end

  private

  def render_addizione(operation)
    config = operation['config'] || {}

    # Genera valori casuali basati sulla config
    max_value = config['max_value'] || 20
    min_value = config['min_value'] || 1

    operand1 = rand(min_value..max_value)
    operand2 = rand(min_value..max_value)

    # Crea oggetto Addizione
    addizione = Addizione.new(addends: [operand1, operand2], operator: '+')

    html = []
    html << %Q(<div class="operation-container" data-operation-id="#{operation['id']}" data-operation-type="addizione">)

    if @view_context
      # Usa il partial esistente
      html << @view_context.render(
        partial: 'strumenti/addizioni/column_addition',
        locals: { addizione: addizione, show_toolbar: false }
      )
    else
      # Fallback HTML semplice
      html << %Q(<div class="p-4 border rounded">)
      html << %Q(<div class="text-center font-mono text-2xl">)
      html << %Q(<div>#{operand1}</div>)
      html << %Q(<div class="border-b-2">+ #{operand2}</div>)
      html << %Q(<div class="mt-2">= #{operand1 + operand2}</div>)
      html << %Q(</div>)
      html << %Q(</div>)
    end

    html << %Q(</div>)
    html.join("\n")
  end

  def render_sottrazione(operation)
    config = operation['config'] || {}

    # Genera valori casuali basati sulla config
    max_value = config['max_value'] || 20
    min_value = config['min_value'] || 1

    operand1 = rand((min_value + 5)..max_value)
    operand2 = rand(min_value..[operand1 - 1, max_value].min)

    # Crea oggetto per sottrazione (usa Addizione con operatore -)
    sottrazione = Addizione.new(addends: [operand1, operand2], operator: '-')

    html = []
    html << %Q(<div class="operation-container" data-operation-id="#{operation['id']}" data-operation-type="sottrazione">)

    if @view_context
      # Usa il partial esistente
      html << @view_context.render(
        partial: 'strumenti/sottrazioni/column_subtraction',
        locals: { sottrazione: sottrazione, show_toolbar: false }
      )
    else
      # Fallback HTML semplice
      html << %Q(<div class="p-4 border rounded">)
      html << %Q(<div class="text-center font-mono text-2xl">)
      html << %Q(<div>#{operand1}</div>)
      html << %Q(<div class="border-b-2">- #{operand2}</div>)
      html << %Q(<div class="mt-2">= #{operand1 - operand2}</div>)
      html << %Q(</div>)
      html << %Q(</div>)
    end

    html << %Q(</div>)
    html.join("\n")
  end

  def render_moltiplicazione(operation)
    config = operation['config'] || {}

    # Genera valori casuali basati sulla config
    operand1 = rand((config['min_table'] || 1)..(config['max_table'] || 10))
    operand2 = rand((config['min_multiplier'] || 1)..(config['max_multiplier'] || 10))

    # Crea oggetto per moltiplicazione
    moltiplicazione = Addizione.new(addends: [operand1, operand2], operator: '×')

    html = []
    html << %Q(<div class="operation-container" data-operation-id="#{operation['id']}" data-operation-type="moltiplicazione">)

    if @view_context
      # Usa il partial esistente
      html << @view_context.render(
        partial: 'strumenti/moltiplicazioni/column_multiplication',
        locals: { moltiplicazione: moltiplicazione, show_toolbar: false }
      )
    else
      # Fallback HTML semplice
      html << %Q(<div class="p-4 border rounded">)
      html << %Q(<div class="text-center font-mono text-2xl">)
      html << %Q(<div>#{operand1}</div>)
      html << %Q(<div class="border-b-2">× #{operand2}</div>)
      html << %Q(<div class="mt-2">= #{operand1 * operand2}</div>)
      html << %Q(</div>)
      html << %Q(</div>)
    end

    html << %Q(</div>)
    html.join("\n")
  end

  def render_abaco(operation)
    config = operation['config'] || {}

    # Genera valore casuale basato sulla config
    value = rand((config['min_value'] || 1)..(config['max_value'] || 100))

    # Crea oggetto Abaco
    abaco = Abaco.new(number: value, editable: true, show_value: false)

    html = []
    html << %Q(<div class="operation-container" data-operation-id="#{operation['id']}" data-operation-type="abaco">)

    if @view_context
      # Usa il partial esistente
      html << @view_context.render(
        partial: 'strumenti/abaco/abaco',
        locals: { abaco: abaco }
      )
    else
      # Fallback HTML semplice
      html << %Q(<div class="p-4 border rounded">)
      html << %Q(<div class="text-center">)
      html << %Q(<p class="text-lg font-semibold mb-2">Abaco: #{value}</p>)
      html << %Q(<div class="grid grid-cols-3 gap-2">)
      html << %Q(<div><span class="text-sm">C:</span> #{value / 100}</div>)
      html << %Q(<div><span class="text-sm">D:</span> #{(value % 100) / 10}</div>)
      html << %Q(<div><span class="text-sm">U:</span> #{value % 10}</div>)
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