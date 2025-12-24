# Design: Refactoring Esercizi con DelegatedType

**Data:** 2025-12-24
**Stato:** Approvato
**Scope:** Addizione, Sottrazione (estendibile a Moltiplicazione, Divisione, Abaco)

## Obiettivo

Refactoring del sistema esercizi usando il pattern DelegatedType di Rails per:
- Persistere le singole operazioni (addizioni, sottrazioni, etc.) nel database
- Permettere a un esercizio di contenere più operazioni di tipi diversi
- Rendere il sistema estendibile a nuovi tipi di "question"

## Architettura

```
┌─────────────────────────────────────────────────────────────────┐
│ ESERCIZIO                                                       │
│ title, slug, account_id, creator_id, ...                       │
├─────────────────────────────────────────────────────────────────┤
│ has_many :questions                                             │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Question        │  │ Question        │  │ Question        │ │
│  │ position: 0     │  │ position: 1     │  │ position: 2     │ │
│  │ questionable:   │  │ questionable:   │  │ questionable:   │ │
│  │ → Addizione     │  │ → Addizione     │  │ → Sottrazione   │ │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘ │
│           │                    │                    │           │
│           ▼                    ▼                    ▼           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Addizione (AR)  │  │ Addizione (AR)  │  │ Sottrazione(AR) │ │
│  │ data: {...}     │  │ data: {...}     │  │ data: {...}     │ │
│  │                 │  │                 │  │                 │ │
│  │ → to_renderer   │  │ → to_renderer   │  │ → to_renderer   │ │
│  │ → Addizione::   │  │ → Addizione::   │  │ → Sottrazione:: │ │
│  │   Renderer      │  │   Renderer      │  │   Renderer      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**Flusso:**
1. `Esercizio` ha molte `Question`
2. Ogni `Question` delega a un tipo specifico (`Addizione`, `Sottrazione`)
3. Il tipo specifico ha un campo `data` JSON con la configurazione
4. `to_renderer` restituisce il PORO (`Addizione::Renderer`) per la view

## Database

### Migrazione: create_questions

```ruby
create_table :questions do |t|
  t.references :esercizio, null: false, foreign_key: true
  t.references :account, foreign_key: true
  t.references :creator, foreign_key: { to_table: :users }
  t.string :questionable_type, null: false
  t.integer :questionable_id, null: false
  t.integer :position, default: 0
  t.integer :difficulty
  t.integer :points
  t.integer :time_limit

  t.timestamps
end

add_index :questions, [:questionable_type, :questionable_id]
add_index :questions, [:esercizio_id, :position]
```

### Migrazione: create_addizioni

```ruby
create_table :addizioni do |t|
  t.json :data, null: false, default: {}

  t.timestamps
end
```

### Migrazione: create_sottrazioni

```ruby
create_table :sottrazioni do |t|
  t.json :data, null: false, default: {}

  t.timestamps
end
```

## Models

### app/models/question.rb

```ruby
class Question < ApplicationRecord
  belongs_to :esercizio
  belongs_to :account, optional: true
  belongs_to :creator, class_name: "User", optional: true

  delegated_type :questionable, types: %w[Addizione Sottrazione]

  scope :ordered, -> { order(:position) }
end
```

### app/models/concerns/questionable.rb

```ruby
module Questionable
  extend ActiveSupport::Concern

  included do
    has_one :question, as: :questionable, touch: true, dependent: :destroy
    serialize :data, coder: JSON, type: Hash
  end

  def to_renderer
    raise NotImplementedError, "#{self.class} must implement #to_renderer"
  end
end
```

### app/models/addizione.rb (nuovo ActiveRecord)

```ruby
class Addizione < ApplicationRecord
  include Questionable

  def to_renderer
    Addizione::Renderer.new(**data.symbolize_keys)
  end
end
```

### app/models/sottrazione.rb (nuovo ActiveRecord)

```ruby
class Sottrazione < ApplicationRecord
  include Questionable

  def to_renderer
    Sottrazione::Renderer.new(**data.symbolize_keys)
  end
end
```

### app/models/esercizio.rb (modifica)

```ruby
class Esercizio < ApplicationRecord
  # ... existing code ...

  has_many :questions, -> { ordered }, dependent: :destroy

  # RIMUOVERE:
  # - serialize :content, coder: JSON, type: Hash
  # - metodi add_operation, remove_operation, operations, reorder_operations
  # - ensure_content_structure, ensure_defaults per content
end
```

## Struttura File Renderers

I PORO esistenti vengono spostati in un namespace:

| Da | A |
|----|---|
| `app/models/addizione.rb` | `app/models/addizione/renderer.rb` |
| `app/models/sottrazione.rb` | `app/models/sottrazione/renderer.rb` |

### app/models/addizione/renderer.rb

```ruby
# frozen_string_literal: true

class Addizione
  class Renderer
    # Tutto il codice attuale di Addizione PORO
    # Nessuna modifica alla logica, solo namespace

    attr_reader :addends, :operator, :result, :max_digits, ...

    def initialize(addends:, operator: "+", **options)
      # ... codice esistente ...
    end

    def to_grid_matrix
      # ... codice esistente ...
    end

    # ... resto del codice ...
  end
end
```

### app/models/sottrazione/renderer.rb

```ruby
# frozen_string_literal: true

class Sottrazione
  class Renderer
    # Tutto il codice attuale di Sottrazione PORO
    # Nessuna modifica alla logica, solo namespace

    attr_reader :minuend, :subtrahend, :result, ...

    def initialize(minuend:, subtrahend:, **options)
      # ... codice esistente ...
    end

    def to_grid_matrix
      # ... codice esistente ...
    end

    # ... resto del codice ...
  end
end
```

## Uso

### Rendering nelle view

```erb
<%# app/views/esercizi/show.html.erb %>

<% @esercizio.questions.each do |question| %>
  <div class="question" data-position="<%= question.position %>">
    <%= render "shared/quaderno_grid",
               **question.questionable.to_renderer.to_grid_matrix %>
  </div>
<% end %>
```

### Creazione questions

```ruby
# Creazione singola
config = { "addends" => ["234", "567"], "operator" => "+" }

esercizio.questions.create!(
  questionable: Addizione.create!(data: config),
  position: 0,
  points: 10,
  account: Current.account,
  creator: Current.user
)

# Creazione multipla
[
  { type: "Addizione", data: { "addends" => ["100", "200"] } },
  { type: "Sottrazione", data: { "minuend" => "500", "subtrahend" => "123" } }
].each_with_index do |q, idx|
  klass = q[:type].constantize
  esercizio.questions.create!(
    questionable: klass.create!(data: q[:data]),
    position: idx
  )
end
```

### Query DelegatedType

```ruby
# Tutte le addizioni di un esercizio
esercizio.questions.addizioni

# Verifica tipo
question.addizione?      # true/false
question.sottrazione?    # true/false

# Accesso diretto al tipo
question.addizione       # restituisce Addizione o nil
question.questionable    # restituisce Addizione o Sottrazione
```

## Piano di Implementazione

### File da creare

1. `db/migrate/XXXX_create_questions.rb`
2. `db/migrate/XXXX_create_addizioni.rb`
3. `db/migrate/XXXX_create_sottrazioni.rb`
4. `app/models/question.rb`
5. `app/models/concerns/questionable.rb`
6. `app/models/addizione.rb` (nuovo AR)
7. `app/models/addizione/renderer.rb` (ex PORO)
8. `app/models/sottrazione.rb` (nuovo AR)
9. `app/models/sottrazione/renderer.rb` (ex PORO)

### File da modificare

1. `app/models/esercizio.rb` - aggiungi `has_many :questions`, rimuovi metodi operations

### Ordine operazioni

1. Crea migrazioni
2. Esegui `rails db:migrate`
3. Crea concern `Questionable`
4. Crea model `Question`
5. Sposta PORO in `addizione/renderer.rb` e `sottrazione/renderer.rb`
6. Crea model AR `Addizione` e `Sottrazione`
7. Modifica `Esercizio`
8. Aggiorna view che usano i renderer

## Estensioni Future

Per aggiungere nuovi tipi (Moltiplicazione, Divisione, Abaco):

1. Crea migrazione per la nuova tabella (es. `create_moltiplicazioni`)
2. Sposta PORO in `moltiplicazione/renderer.rb`
3. Crea model AR con `include Questionable`
4. Aggiungi il tipo in `Question`: `delegated_type :questionable, types: %w[Addizione Sottrazione Moltiplicazione]`

## Note

- I PORO Renderer mantengono tutta la logica di calcolo e rendering esistente
- Le opzioni di visualizzazione (show_solution, show_toolbar, etc.) restano nei renderer, passate via `data`
- Nessuna migrazione dati necessaria (si parte da zero)
