# Design: Concern Parseable per Operazioni Matematiche

**Data:** 2025-12-29
**Obiettivo:** Semplificare i model Addizione, Sottrazione, Moltiplicazione, Divisione eliminando la duplicazione del codice di parsing

## Problema

I 4 model delle operazioni matematiche hanno metodi di parsing quasi identici:
- `parse(operation_string)`
- `parse_multiple(operations_string)`
- `from_string(operation_string, **options)`
- `from_strings(operations_string, **options)`
- `build_renderer(operation_string, **options)`
- `build_renderers(operations_string, **options)`

Inoltre esiste `OperationParser` (concern) che duplica ulteriormente questa logica per il bulk import.

## Soluzione

Creare un concern `Parseable` che:
1. Fornisce un **DSL dichiarativo** per configurare operatore e campi
2. Implementa tutta la **logica comune** di parsing
3. Permette **override** per casi speciali (Addizione con N addendi, validazioni custom)
4. Mantiene un **registry automatico** dei tipi per bulk operations
5. **Elimina** `OperationParser` (la sua funzionalità viene assorbita)

## Struttura del Concern

```ruby
# app/models/concerns/parseable.rb
module Parseable
  extend ActiveSupport::Concern

  # Registry dei tipi
  mattr_accessor :registered_types, default: []

  included do
    Parseable.registered_types << self unless Parseable.registered_types.include?(self)
  end

  # Metodo di modulo per bulk creation
  def self.create_all_from_text(text, esercizio:, options: {})
    return [] if text.blank?

    lines = text.split(/[;\n,]/).map(&:strip).reject(&:blank?)

    lines.filter_map do |line|
      klass = registered_types.find { |k| line.gsub(/\s+/, "").match?(k.operator_regex) }
      next unless klass

      parsed = klass.parse(line)
      next unless parsed

      questionable = klass.create!(klass.build_options(parsed, options))
      esercizio.questions.create!(questionable: questionable)
    end
  end

  class_methods do
    # DSL
    def parseable(operator:, fields:)
      @operator_regex = operator
      @field_names = fields
    end

    attr_reader :operator_regex, :field_names

    # Override nei model per validazioni custom
    def valid_operation?(parsed) = true

    # Override in Addizione per gestire N operandi
    def parse_result(parts)
      field_names.zip(parts).to_h
    end

    # Parse singola operazione
    def parse(operation_string)
      return nil if operation_string.blank?

      cleaned = operation_string.gsub(/\s+/, "")
      return nil unless cleaned.match?(operator_regex)

      parts = cleaned.split(operator_regex).map(&:strip).reject(&:blank?)
      return nil if parts.empty?
      return nil unless parts.all? { |p| valid_number?(p) }

      parsed = parse_result(parts.map { |p| p.gsub(",", ".") })
      return nil unless valid_operation?(parsed)

      parsed
    end

    # Parse multiple da testo
    def parse_multiple(text)
      return [] if text.blank?

      text.split(/[;\n,]/)
          .map(&:strip)
          .reject(&:blank?)
          .filter_map { |line| parse(line) }
    end

    # --- Factory: Renderer (oggetti in memoria) ---

    def build_renderer(operation_string, **options)
      parsed = parse(operation_string)
      return nil unless parsed

      Renderer.new(**parsed, **options)
    end

    def build_renderers(operations_string, **options)
      parse_multiple(operations_string).map do |parsed|
        Renderer.new(**parsed, **options)
      end
    end

    # --- Factory: DB Records ---

    def from_string(operation_string, **options)
      parsed = parse(operation_string)
      return nil unless parsed

      create(**parsed, **options)
    end

    def from_strings(operations_string, **options)
      parse_multiple(operations_string).map do |parsed|
        create(**parsed, **options)
      end
    end

    private

    def valid_number?(str)
      str.match?(/^\d+([.,]\d+)?$/)
    end
  end

  # Istanza: converte record DB in Renderer
  def to_renderer
    Renderer.new(**data.symbolize_keys)
  end
end
```

## Model Refactored

### Addizione (override di `parse_result` per N addendi)

```ruby
class Addizione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Parseable
  include Addizione::Calculation

  self.table_name = "addizioni"

  store_accessor :data, :addends, :operator, :title,
                 :show_exercise, :show_addends, :show_solution,
                 :show_toolbar, :show_carry, :show_labels, :show_addend_indices

  after_save :reset_calculations!

  parseable operator: /[+]/, fields: [:addends]

  def self.parse_result(parts)
    { addends: parts }
  end
end
```

### Sottrazione (override di `valid_operation?`)

```ruby
class Sottrazione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Parseable
  include Sottrazione::Calculation

  self.table_name = "sottrazioni"

  store_accessor :data, :minuend, :subtrahend, :title,
                 :show_exercise, :show_minuend_subtrahend, :show_solution,
                 :show_toolbar, :show_borrow, :show_labels

  after_save :reset_calculations!

  parseable operator: /[-]/, fields: [:minuend, :subtrahend]

  def self.valid_operation?(parsed)
    parsed[:minuend].to_f >= parsed[:subtrahend].to_f
  end
end
```

### Moltiplicazione (nessun override)

```ruby
class Moltiplicazione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Parseable

  self.table_name = "moltiplicazioni"

  store_accessor :data, :multiplicand, :multiplier, :title,
                 :show_exercise, :show_multiplicand_multiplier, :show_solution,
                 :show_toolbar, :show_partial_products, :show_carry, :show_labels

  parseable operator: /[x*×]/i, fields: [:multiplicand, :multiplier]
end
```

### Divisione (override di `valid_operation?`)

```ruby
class Divisione < ApplicationRecord
  include Questionable
  include GenericOptions
  include Parseable

  self.table_name = "divisioni"

  store_accessor :data, :dividend, :divisor, :title,
                 :show_exercise, :show_dividend_divisor, :show_solution,
                 :show_toolbar, :show_steps

  parseable operator: /[\/÷:]/, fields: [:dividend, :divisor]

  def self.valid_operation?(parsed)
    parsed[:divisor].to_f != 0
  end
end
```

## BulkQuestionsController Semplificato

```ruby
class Dashboard::Esercizi::BulkQuestionsController < Dashboard::Esercizi::BaseController
  def new
  end

  def create
    Parseable.create_all_from_text(
      params[:operations_text],
      esercizio: @esercizio,
      options: bulk_options
    )
    redirect_to edit_dashboard_esercizio_path(@esercizio)
  end

  private

  def bulk_options
    params.permit(:show_first_operand, :show_second_operand, :show_result,
                  :show_toolbar, :grid_style).to_h.symbolize_keys
  end
end
```

## File da Modificare

| Azione | File |
|--------|------|
| Creare | `app/models/concerns/parseable.rb` |
| Modificare | `app/models/addizione.rb` |
| Modificare | `app/models/sottrazione.rb` |
| Modificare | `app/models/moltiplicazione.rb` |
| Modificare | `app/models/divisione.rb` |
| Modificare | `app/controllers/dashboard/esercizi/bulk_questions_controller.rb` |
| Rimuovere | `app/models/concerns/operation_parser.rb` |

## Impatto

- **Riduzione LOC:** ~200 linee rimosse dai model
- **API invariata:** `Addizione.build_renderers("12+3")` continua a funzionare
- **Controller strumenti:** nessuna modifica richiesta
- **Manutenibilità:** aggiungere un nuovo tipo di operazione richiede solo definire il DSL

## Rischi

- I test esistenti per i metodi di parsing devono passare
- Verificare che `Renderer.new` accetti i parametri nel formato corretto per ogni tipo
