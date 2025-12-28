# Design: Form Bulk Insert Questions

**Data:** 2025-12-28
**Stato:** Approvato

## Obiettivo

Creare un form nella sidebar della pagina edit esercizio che permetta di inserire multiple operazioni matematiche in una volta sola, con parsing automatico del tipo di operazione.

## Decisioni di Design

- **Posizione:** Card nella sidebar, sopra "Informazioni"
- **Opzioni:** Solo comuni a tutti i tipi (show_toolbar, show_solution)
- **Sintassi operatori:** `+` addizione, `-` sottrazione, `x`/`*` moltiplicazione, `/`/`:` divisione
- **Feedback:** Nessuno durante inserimento, solo flash notice dopo creazione
- **Post-inserimento:** Textarea svuotata, redirect alla stessa pagina

## Architettura

### Parser Universale

```ruby
# app/models/concerns/operation_parser.rb
# Input: "123+45\n67-23\n12x4\n144/12"
# Output:
[
  { type: "Addizione", data: { addends: ["123", "45"] } },
  { type: "Sottrazione", data: { minuend: "67", subtrahend: "23" } },
  { type: "Moltiplicazione", data: { multiplicand: "12", multiplier: "4" } },
  { type: "Divisione", data: { dividend: "144", divisor: "12" } }
]
```

### Regole di Parsing

- Separatori: newline, punto e virgola, virgola
- Operatori: `+`, `-`, `x`/`*`, `/`/`:`
- Spazi ignorati
- Righe invalide ignorate silenziosamente
- Addizione supporta più addendi (1+2+3)

### Route (RESTful)

```ruby
namespace :dashboard do
  resources :esercizi do
    resource :bulk_questions, only: [:new, :create]
  end
end
```

### Controller

```ruby
# app/controllers/dashboard/esercizi/bulk_questions_controller.rb
class Dashboard::Esercizi::BulkQuestionsController < Dashboard::BaseController
  def create
    parsed = OperationParser.parse_all(params[:operations_text])
    options = { show_toolbar: params.dig(:options, :show_toolbar) == "1",
                show_solution: params.dig(:options, :show_solution) == "1" }

    created_count = 0
    parsed.each do |op|
      klass = op[:type].constantize
      questionable = klass.create!(data: op[:data].merge(options))
      @esercizio.questions.create!(
        questionable: questionable,
        position: @esercizio.questions.count,
        account: Current.account,
        creator: Current.user
      )
      created_count += 1
    end

    redirect_to edit_dashboard_esercizio_path(@esercizio),
                notice: "#{created_count} operazioni aggiunte"
  end
end
```

### View

Card nella sidebar con:
- Textarea (font mono, placeholder con esempi)
- Checkbox show_toolbar (default checked)
- Checkbox show_solution (default unchecked)
- Bottone submit

## File da Creare

1. `app/models/concerns/operation_parser.rb`
2. `app/controllers/dashboard/esercizi/bulk_questions_controller.rb`

## File da Modificare

1. `config/routes.rb`
2. `app/views/dashboard/esercizi/edit.html.erb`

## Non Incluso (YAGNI)

- Anteprima live
- Validazione client-side
- Opzioni specifiche per tipo
- Supporto Abaco
