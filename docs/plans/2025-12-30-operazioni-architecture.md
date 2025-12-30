# Architettura Operazioni Matematiche

Documentazione dell'architettura per Addizione, Sottrazione, Moltiplicazione e Divisione.

## Panoramica

Ogni operazione matematica segue un pattern **Model-Renderer-Partial**:

```
┌──────────────────────────────────────────────────────────────────────────┐
│  Model AR                 Renderer                    Partial            │
│  ─────────────            ─────────                   ───────────        │
│  Addizione.rb         →   Addizione::Renderer     →   _addizione_grid    │
│  Sottrazione.rb       →   Sottrazione::Renderer   →   _sottrazione_grid  │
│  Moltiplicazione.rb   →   Moltiplicazione::Renderer → _moltiplicazione_grid │
│  Divisione.rb         →   Divisione::Renderer     →   _divisione_grid    │
└──────────────────────────────────────────────────────────────────────────┘
```

**I tre ruoli:**
1. **Model ActiveRecord** - Persistenza in DB con campo JSON `data`, include `Parseable` per creare operazioni da stringa
2. **Renderer** - Oggetto in memoria che calcola la rappresentazione visuale (grid matrix)
3. **Partial** - Renderizza l'HTML dalla grid matrix (4 partial quasi identici, solo colori diversi)

---

## Concern `Parseable` - Factory per Operazioni

`Parseable` è un DSL che permette di creare operazioni da stringhe di testo.

### Definizione nel model

```ruby
class Addizione < ApplicationRecord
  include Parseable
  parseable operator: /[+]/, fields: [:addends]
end

class Sottrazione < ApplicationRecord
  include Parseable
  parseable operator: /[-]/, fields: [:minuend, :subtrahend]
end

class Moltiplicazione < ApplicationRecord
  include Parseable
  parseable operator: /[x*×]/i, fields: [:multiplicand, :multiplier]
end

class Divisione < ApplicationRecord
  include Parseable
  parseable operator: /[\/÷:]/, fields: [:dividend, :divisor]
end
```

### Flusso di parsing

```
"234 + 567"  →  Addizione.parse("234 + 567")  →  { addends: ["234", "567"] }
"100 - 35"   →  Sottrazione.parse("100 - 35") →  { minuend: "100", subtrahend: "35" }
"12 x 5"     →  Moltiplicazione.parse(...)    →  { multiplicand: "12", multiplier: "5" }
"144 : 12"   →  Divisione.parse(...)          →  { dividend: "144", divisor: "12" }
```

### Due modalità di creazione

| Metodo | Output | Uso |
|--------|--------|-----|
| `build_renderer("234+567")` | `Addizione::Renderer` (in memoria) | Strumenti interattivi |
| `from_string("234+567")` | `Addizione` (salvato in DB) | Esercizi persistenti |

### Bulk creation per esercizi

```ruby
Parseable.create_all_from_text("234+567; 100-35; 12x5", esercizio: @esercizio)
# Crea 3 Question con i rispettivi questionable (Addizione, Sottrazione, Moltiplicazione)
```

---

## Concern `Calculation` - Logica Matematica Condivisa

I moduli `Calculation` contengono tutta la logica matematica e sono condivisi tra Model AR e Renderer.

### Addizione::Calculation

```ruby
module Addizione::Calculation
  def result           # Calcola somma
  def parsed_addends   # Array numeri [234, 567]
  def addends_digits   # Array cifre per colonna [["2","3","4"], ["5","6","7"]]
  def result_digits    # Cifre risultato ["8","0","1"]
  def carries          # Riporti ["", "1", ""]
  def max_digits       # Numero max cifre (per allineamento)
  def has_decimals?    # Supporto virgola
end
```

### Condivisione tra Model e Renderer

```
┌─────────────────────────────────────────────────────────────────┐
│  Addizione (Model AR)          Addizione::Renderer              │
│  include Addizione::Calculation    include Addizione::Calculation   │
│  ─────────────────────────────────────────────────────────────  │
│  Persiste in DB                Solo in memoria                  │
│  data JSON: {addends: [...]}   @addends = [...]                 │
│                                                                 │
│  Entrambi possono chiamare:                                     │
│  result, carries, max_digits, has_decimals?, etc.               │
└─────────────────────────────────────────────────────────────────┘
```

### Specificità per operazione

| Operazione | Calculation | Metodi specifici |
|------------|-------------|------------------|
| Addizione | `carries` | Riporti (colonna per colonna) |
| Sottrazione | `borrows`, `crossed_out` | Prestiti + cifre barrate |
| Moltiplicazione | (nel Renderer) | Prodotti parziali, riporti multipli |
| Divisione | (nel Renderer) | `division_steps` per passi intermedi |

**Nota:** Moltiplicazione e Divisione non hanno un Calculation separato - la logica è direttamente nel Renderer perché più complessa e specifica per la visualizzazione.

---

## Renderer e `to_grid_matrix`

Il Renderer trasforma i dati matematici in una matrice di celle che il partial renderizza.

### Inizializzazione

```ruby
renderer = Addizione::Renderer.new(
  addends: [234, 567],
  show_addends: true,      # Mostra operandi pre-compilati
  show_solution: false,    # Nascondi risultato
  show_carry: true,        # Mostra riga riporti
  show_labels: true,       # Mostra etichette (u, da, h)
  show_toolbar: true,      # Barra verifica/cancella
  grid_style: :quaderno    # :quaderno o :column
)
```

### Output di `to_grid_matrix`

```ruby
{
  columns: 6,                    # Numero colonne totali
  cell_size: "2.5em",           # Dimensione celle CSS
  controller: "quaderno",        # Stimulus controller
  rows: [
    { type: :cells, cells: [...] },   # Riga etichette
    { type: :cells, cells: [...] },   # Riga riporti
    { type: :cells, cells: [...] },   # Riga addendo 1
    { type: :cells, cells: [...] },   # Riga addendo 2
    { type: :result, cells: [...] },  # Riga risultato (bordo spesso)
    { type: :toolbar }                # Toolbar verifica
  ]
}
```

### Struttura di una cella

```ruby
{
  type: :digit,              # :digit, :sign, :label, :empty, :static
  value: "5",                # Valore corretto
  target: "input",           # Stimulus target: input, carry, result, step
  editable: true,            # Input modificabile
  show_value: false,         # Se pre-compilare
  classes: "text-gray-800",  # Classi Tailwind
  nav_direction: "ltr",      # Direzione navigazione tastiera
  comma_spot: {...},         # Per virgola cliccabile (moltiplicazione)
  comma_shift: {...}         # Per virgola spostabile (divisione)
}
```

### Tipi di righe

| Tipo | Descrizione |
|------|-------------|
| `:cells` | Riga normale con celle |
| `:result` | Riga risultato (bordo spesso sopra) |
| `:empty` | Riga vuota (margini) |
| `:toolbar` | Barra strumenti |

---

## Partial

I 4 partial sono quasi identici (98% codice duplicato). Differenze:

| Partial | Colore bordo (column style) | Colonne skip |
|---------|----------------------------|--------------|
| `_addizione_grid` | `border-blue-400` | prima, segno, ultima |
| `_sottrazione_grid` | `border-red-400` | prima, segno, ultima |
| `_moltiplicazione_grid` | `border-green-400` | prima, segno, ultima |
| `_divisione_grid` | `border-orange-400` | solo prima e ultima (no segno) |

### Logica di rendering (comune a tutti)

```erb
<% rows.each do |row| %>
  <% case row[:type] %>
  <% when :empty %>
    <!-- Celle vuote per margini -->
  <% when :cells, :result %>
    <% row[:cells].each do |cell| %>
      <% case cell[:type] %>
      <% when :digit %>
        <input data-quaderno-target="<%= cell[:target] %>"
               data-correct-answer="<%= cell[:value] %>"
               value="<%= cell[:show_value] ? cell[:value] : '' %>">
      <% when :sign %>
        <div><%= cell[:value] %></div>  <!-- +, -, ×, =, : -->
      <% when :label %>
        <div><%= cell[:value] %></div>  <!-- u, da, h, k -->
      <% end %>
    <% end %>
  <% when :toolbar %>
    <%= render "strumenti/quaderno_toolbar" %>
  <% end %>
<% end %>
```

---

## `GenericOptions` - Normalizzazione Opzioni

Ogni operazione ha nomi diversi per concetti simili. `GenericOptions` permette di usare nomi generici che vengono tradotti automaticamente.

### Il problema

```ruby
# Ogni operazione usa nomi diversi per "mostra operandi"
Addizione:        show_addends
Sottrazione:      show_minuend_subtrahend
Moltiplicazione:  show_multiplicand_multiplier
Divisione:        show_dividend_divisor
```

### Mapping automatico

```ruby
MAPPINGS = {
  "Addizione" => {
    show_operands: :show_addends,
    show_carry: :show_carry,
    layout: :grid_style
  },
  "Sottrazione" => {
    show_operands: :show_minuend_subtrahend,
    show_carry: :show_borrow,        # "carry" diventa "borrow"
    layout: :grid_style
  },
  "Moltiplicazione" => {
    show_operands: :show_multiplicand_multiplier,
    show_steps: :show_partial_products,  # "steps" = prodotti parziali
    layout: :grid_style
  },
  "Divisione" => {
    show_operands: :show_dividend_divisor,
    show_steps: :show_steps,
    layout: :grid_style
  }
}

# Opzioni che passano senza traduzione
PASSTHROUGH = [:show_solution, :show_toolbar, :show_labels, :title]
```

### Uso pratico (bulk creation)

```ruby
# Dal controller/form - opzioni generiche
options = {
  show_operands: true,
  show_solution: false,
  show_carry: true,
  layout: :quaderno
}

# Parseable.create_all_from_text traduce automaticamente
Parseable.create_all_from_text("234+567; 100-35", esercizio: @ex, options: options)

# Per Addizione diventa: { show_addends: true, show_carry: true, ... }
# Per Sottrazione diventa: { show_minuend_subtrahend: true, show_borrow: true, ... }
```

---

## Flusso Completo End-to-End

```
1. INPUT UTENTE
   "234 + 567; 12,5 + 3,25"
          │
          ▼
2. PARSING (Parseable)
   Addizione.build_renderers("234+567; 12,5+3,25")
          │
          ▼
3. RENDERER (in memoria)
   [Addizione::Renderer, Addizione::Renderer]
   - include Addizione::Calculation
   - calcola: result, carries, max_digits, etc.
          │
          ▼
4. GRID MATRIX (to_grid_matrix)
   { columns: 6, rows: [{cells: [...]}, ...] }
          │
          ▼
5. PARTIAL (ERB)
   render "_addizione_grid", grid: renderer.to_grid_matrix
          │
          ▼
6. HTML + STIMULUS
   <div data-controller="quaderno">
     <input data-quaderno-target="input" data-correct-answer="8">
     <input data-quaderno-target="carry" data-correct-answer="1">
     ...
   </div>
```

---

## Riepilogo Architettura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              CONCERNS                                    │
├─────────────────────────────────────────────────────────────────────────┤
│  Parseable          GenericOptions       Calculation (Add/Sot)          │
│  - DSL parsing      - Normalizza         - Logica matematica            │
│  - Factory          opzioni generiche    - Condivisa Model/Renderer     │
│  - Bulk creation    in specifiche                                       │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         4 OPERAZIONI                                     │
├──────────────────┬──────────────────┬───────────────────┬───────────────┤
│  Addizione       │  Sottrazione     │  Moltiplicazione  │  Divisione    │
│  - Model AR      │  - Model AR      │  - Model AR       │  - Model AR   │
│  - Calculation   │  - Calculation   │  - (nel Renderer) │  - (nel Rend) │
│  - Renderer      │  - Renderer      │  - Renderer       │  - Renderer   │
│  - Partial       │  - Partial       │  - Partial        │  - Partial    │
└──────────────────┴──────────────────┴───────────────────┴───────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        to_grid_matrix                                    │
│  Struttura dati uniforme: { columns, rows: [{type, cells: [...]}] }     │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    4 PARTIAL (98% duplicati)                            │
│  _addizione_grid │ _sottrazione_grid │ _moltip_grid │ _divisione_grid   │
│  (blu)           │ (rosso)           │ (verde)      │ (arancione)       │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     STIMULUS CONTROLLER                                  │
│  quaderno_controller.js - navigazione, verifica, reset                  │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## File di riferimento

### Models
- `app/models/addizione.rb`
- `app/models/sottrazione.rb`
- `app/models/moltiplicazione.rb`
- `app/models/divisione.rb`

### Calculations
- `app/models/addizione/calculation.rb`
- `app/models/sottrazione/calculation.rb`

### Renderers
- `app/models/addizione/renderer.rb`
- `app/models/sottrazione/renderer.rb`
- `app/models/moltiplicazione/renderer.rb`
- `app/models/divisione/renderer.rb`

### Concerns
- `app/models/concerns/parseable.rb`
- `app/models/concerns/generic_options.rb`

### Partials
- `app/views/strumenti/addizioni/_addizione_grid.html.erb`
- `app/views/strumenti/sottrazioni/_sottrazione_grid.html.erb`
- `app/views/strumenti/moltiplicazioni/_moltiplicazione_grid.html.erb`
- `app/views/strumenti/divisioni/_divisione_grid.html.erb`

### Stimulus
- `app/javascript/controllers/quaderno_controller.js`
