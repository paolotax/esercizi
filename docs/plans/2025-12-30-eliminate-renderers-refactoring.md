# Piano: Eliminare i Renderer - Semplificazione Architettura

## Obiettivo

Eliminare la duplicazione tra Model AR e Renderer PORO, unificando tutto nel Model.

## Situazione Attuale

```
Model AR (dati)           Renderer PORO (rendering)
─────────────────         ──────────────────────────
Addizione                 Addizione::Renderer
  include Calculation       include Calculation  ← duplicato!
  addends, operator         addends, operator    ← duplicato!
                            + quaderno_*, to_grid_matrix

Sottrazione               Sottrazione::Renderer
  include Calculation       include Calculation  ← duplicato!
  minuend, subtrahend       minuend, subtrahend  ← duplicato!
                            + quaderno_*, to_grid_matrix

Moltiplicazione           Moltiplicazione::Renderer
  (nessun Calculation)      tutta logica dentro  ← ~740 linee!
                            + to_grid_matrix

Divisione                 Divisione::Renderer
  (nessun Calculation)      tutta logica dentro  ← ~590 linee!
                            + to_grid_matrix

Abaco                     Abaco::Renderer
  parse, factory methods    logica colonne/valori
                            + to_partial_params
```

## Architettura Target

```
Model AR (tutto insieme)
────────────────────────
Addizione
  include Addizione::Calculation      # logica matematica
  include Addizione::GridRenderable   # to_grid_matrix, quaderno_*
  def to_renderer = self

Sottrazione
  include Sottrazione::Calculation
  include Sottrazione::GridRenderable
  def to_renderer = self

Moltiplicazione
  include Moltiplicazione::Calculation  # NUOVO - estrarre da Renderer
  include Moltiplicazione::GridRenderable
  def to_renderer = self

Divisione
  include Divisione::Calculation        # NUOVO - estrarre da Renderer
  include Divisione::GridRenderable
  def to_renderer = self

Abaco
  include Abaco::Calculation            # NUOVO - estrarre da Renderer
  def to_renderer = self
```

## Benefici

1. **Nessuna duplicazione** - ogni concetto definito una volta sola
2. **Meno file** - da 2 file per tipo a 1 file + concerns
3. **Più semplice** - `to_renderer` restituisce `self`
4. **Estensibile** - nuovi Questionable seguono lo stesso pattern

---

## Task Checklist

### Fase 1: Aggiornare Questionable e Parseable

- [ ] **1.1** Modificare `Questionable#to_renderer` per restituire `self` di default
- [ ] **1.2** Modificare `Parseable#to_renderer` per restituire `self`
- [ ] **1.3** Modificare `Parseable.build_renderer` → `Parseable.build` (restituisce model non salvato)
- [ ] **1.4** Aggiornare test esistenti

### Fase 2: Refactoring Addizione

- [ ] **2.1** Creare `Addizione::GridRenderable` concern
  - Spostare da Renderer: `quaderno_*` methods, `to_grid_matrix`, `build_*_row` methods
  - Spostare: `column_labels`, `column_colors`, `to_s`
- [ ] **2.2** Aggiungere `include Addizione::GridRenderable` al model
- [ ] **2.3** Rimuovere `to_renderer` custom (usa default da Questionable)
- [ ] **2.4** Aggiornare chiamate `build_renderer` → `build` dove usate
- [ ] **2.5** Verificare test passano
- [ ] **2.6** Eliminare `app/models/addizione/renderer.rb`

### Fase 3: Refactoring Sottrazione

- [ ] **3.1** Creare `Sottrazione::GridRenderable` concern
  - Spostare da Renderer: `quaderno_*` methods, `to_grid_matrix`, `build_*_row` methods
- [ ] **3.2** Aggiungere `include Sottrazione::GridRenderable` al model
- [ ] **3.3** Rimuovere `to_renderer` custom
- [ ] **3.4** Aggiornare chiamate `build_renderer` → `build`
- [ ] **3.5** Verificare test passano
- [ ] **3.6** Eliminare `app/models/sottrazione/renderer.rb`

### Fase 4: Refactoring Moltiplicazione

- [ ] **4.1** Creare `Moltiplicazione::Calculation` concern (NUOVO)
  - Estrarre da Renderer: `normalize_number_string`, `parse_to_number`, `count_decimals`
  - Estrarre: `product`, `multiplicand_digits`, `multiplier_digits`
  - Estrarre: `calculate_partial_carries`, `calculate_sum_carries`, `calculate_direct_multiplication_carries`
  - Estrarre: `partial_products_data`, `result_carries`
- [ ] **4.2** Creare `Moltiplicazione::GridRenderable` concern
  - Spostare da Renderer: `to_grid_matrix`, `build_*_row` methods
  - Spostare: `quaderno_*` methods
- [ ] **4.3** Aggiungere includes al model
- [ ] **4.4** Aggiornare chiamate `build_renderer` → `build`
- [ ] **4.5** Creare test per Calculation
- [ ] **4.6** Verificare test passano
- [ ] **4.7** Eliminare `app/models/moltiplicazione/renderer.rb`

### Fase 5: Refactoring Divisione

- [ ] **5.1** Creare `Divisione::Calculation` concern (NUOVO)
  - Estrarre da Renderer: `normalize_number_string`, `count_decimals`, `to_integer_shifted`
  - Estrarre: `quotient`, `remainder`, `dividend_digits`, `divisor_digits`, `quotient_digits`
  - Estrarre: `division_steps`, `extended_quotient`
  - Estrarre: `has_remainder?`, `exact?`, `quotient_decimal_position`
- [ ] **5.2** Creare `Divisione::GridRenderable` concern
  - Spostare da Renderer: `to_grid_matrix`, `build_*_row` methods
- [ ] **5.3** Aggiungere includes al model
- [ ] **5.4** Aggiornare chiamate `build_renderer` → `build`
- [ ] **5.5** Creare test per Calculation
- [ ] **5.6** Verificare test passano
- [ ] **5.7** Eliminare `app/models/divisione/renderer.rb`

### Fase 6: Refactoring Abaco

- [ ] **6.1** Creare `Abaco::Calculation` concern
  - Estrarre da Renderer: `*_value` methods (migliaia_value, centinaia_value, etc.)
  - Estrarre: `input_*` methods, `total_value`
  - Estrarre: `show_*?` methods, `digit_from_correct_value`
- [ ] **6.2** Aggiungere `include Abaco::Calculation` al model
- [ ] **6.3** Spostare `to_partial_params` nel model (o eliminare se non serve)
- [ ] **6.4** Aggiornare `to_renderer` → `self`
- [ ] **6.5** Aggiornare chiamate `build_renderer` → `build`
- [ ] **6.6** Verificare funzionamento abaco nelle view
- [ ] **6.7** Eliminare `app/models/abaco/renderer.rb`

### Fase 7: Cleanup e Documentazione

- [ ] **7.1** Aggiornare `OperazioniHelper` se necessario
- [ ] **7.2** Verificare tutte le view che usano i renderer
- [ ] **7.3** Rimuovere file renderer eliminati da git
- [ ] **7.4** Aggiornare documentazione (CLAUDE.md se necessario)
- [ ] **7.5** Eseguire test suite completa
- [ ] **7.6** Commit finale

---

## Struttura File Finale

```
app/models/
├── addizione.rb
├── addizione/
│   ├── calculation.rb        # già esistente
│   └── grid_renderable.rb    # NUOVO (da renderer)
│
├── sottrazione.rb
├── sottrazione/
│   ├── calculation.rb        # già esistente
│   └── grid_renderable.rb    # NUOVO (da renderer)
│
├── moltiplicazione.rb
├── moltiplicazione/
│   ├── calculation.rb        # NUOVO (estratto da renderer)
│   └── grid_renderable.rb    # NUOVO (da renderer)
│
├── divisione.rb
├── divisione/
│   ├── calculation.rb        # NUOVO (estratto da renderer)
│   └── grid_renderable.rb    # NUOVO (da renderer)
│
├── abaco.rb
├── abaco/
│   └── calculation.rb        # NUOVO (estratto da renderer)
│
└── concerns/
    ├── questionable.rb       # modificato: to_renderer = self
    └── parseable.rb          # modificato: build invece di build_renderer
```

---

## Note Implementative

### Gestione Attributi

I Renderer usano `attr_reader`/`attr_accessor`, i Model AR usano `store_accessor`.
I metodi del Calculation devono funzionare con entrambi:

```ruby
# Nel Calculation, accedere sempre tramite metodi (non @variabili)
def raw_addends
  @raw_addends ||= Array(addends).map { |a| normalize_number_string(a) }
end
```

Questo funziona perché:
- Nel Model AR: `addends` viene da `store_accessor :data, :addends`
- Nel vecchio Renderer: `addends` veniva da `attr_accessor :addends`

### Inizializzazione Options

Il Renderer aveva defaults nel `initialize`. Nel Model AR usiamo:

```ruby
# Nel model
after_initialize :set_defaults

def set_defaults
  self.show_toolbar ||= false
  self.show_carry ||= true
  # etc.
end
```

Oppure gestire i defaults nei metodi stessi:

```ruby
def show_toolbar?
  show_toolbar.nil? ? false : show_toolbar
end
```

### Parseable.build

```ruby
# Prima
def self.build_renderer(operation_string, **options)
  parsed = parse(operation_string)
  return nil unless parsed
  self::Renderer.new(**parsed, **options)
end

# Dopo
def self.build(operation_string, **options)
  parsed = parse(operation_string)
  return nil unless parsed
  new(data: parsed.merge(options))  # Model AR non persistito
end
```

---

## Stima Effort

| Fase | Complessità | Note |
|------|-------------|------|
| 1. Questionable/Parseable | Bassa | Modifiche semplici |
| 2. Addizione | Media | Calculation già esiste |
| 3. Sottrazione | Media | Calculation già esiste |
| 4. Moltiplicazione | Alta | Estrarre Calculation da 740 linee |
| 5. Divisione | Alta | Estrarre Calculation da 590 linee |
| 6. Abaco | Bassa | Renderer semplice (~150 linee) |
| 7. Cleanup | Bassa | Verifiche e test |

**Ordine consigliato**: 1 → 6 → 2 → 3 → 4 → 5 → 7

Iniziare con Abaco (più semplice) permette di validare il pattern prima di affrontare Moltiplicazione/Divisione.
