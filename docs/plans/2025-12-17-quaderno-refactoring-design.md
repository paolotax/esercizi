# Quaderno Refactoring Design

Data: 2025-12-17

## Obiettivo

Unificare i 4 partial e i 4 controller Stimulus dei quaderni (addizione, sottrazione, moltiplicazione, divisione) in un sistema basato su matrice uniforme.

## Architettura

### Struttura della matrice

Ogni modello Ruby espone `to_grid_matrix` che restituisce:

```ruby
{
  # Configurazione griglia
  columns: 8,                    # numero colonne totali
  cell_size: "2.5em",

  # Controller Stimulus da usare
  controller: "quaderno",        # un solo controller unificato

  # Opzioni visualizzazione
  show_toolbar: true,
  title: "Addizione",

  # La matrice: array di righe
  rows: [
    { type: :empty, height: "2.5em" },
    { type: :cells, height: "1.5em", cells: [...] },  # riporti
    { type: :cells, height: "2.5em", cells: [...] },  # operandi
    { type: :result, height: "2.5em", cells: [...] }, # risultato (bordo spesso sopra)
    { type: :empty, height: "2.5em" },
    { type: :toolbar }
  ]
}
```

### Struttura di ogni cella

```ruby
{
  value: "3",              # risposta corretta (o nil se vuota)
  type: :digit,            # :digit, :carry, :sign, :comma, :empty
  target: "input",         # target Stimulus: input, result, carry, etc.
  editable: true,          # se e' un input o testo statico
  show_value: false,       # se precompilare il valore
  disabled: false,         # input disabilitato
  classes: "text-blue-600", # classi CSS aggiuntive
  nav_direction: "ltr"     # direzione navigazione: ltr o rtl
}
```

## Componenti

### Nuovi file

| File | Descrizione |
|------|-------------|
| `app/views/strumenti/_quaderno_grid.html.erb` | Partial unificato |
| `app/views/strumenti/_quaderno_toolbar.html.erb` | Toolbar estratta |
| `app/javascript/controllers/quaderno_controller.js` | Controller Stimulus unificato |

### File da modificare

| File | Modifica |
|------|----------|
| `app/models/addizione.rb` | Aggiungere `to_grid_matrix` |
| `app/models/sottrazione.rb` | Aggiungere `to_grid_matrix` |
| `app/models/moltiplicazione.rb` | Aggiungere `to_grid_matrix` |
| `app/models/divisione.rb` | Aggiungere `to_grid_matrix` |

### File da rimuovere (dopo migrazione)

- `app/views/strumenti/addizioni/_quaderno_addizione.html.erb`
- `app/views/strumenti/sottrazioni/_quaderno_sottrazione.html.erb`
- `app/views/strumenti/moltiplicazioni/_quaderno_moltiplicazione.html.erb`
- `app/views/strumenti/divisioni/_quaderno_divisione.html.erb`
- `app/javascript/controllers/quaderno_addition_controller.js`
- `app/javascript/controllers/quaderno_subtraction_controller.js`
- `app/javascript/controllers/quaderno_multiplication_controller.js`
- `app/javascript/controllers/quaderno_division_controller.js`

## Controller Stimulus unificato

### Targets

```javascript
static targets = ["cell", "input", "result", "carry", "commaSpot"]
```

### Metodi principali

| Metodo | Funzione |
|--------|----------|
| `connect()` | Setup iniziale, costruisce mappa celle |
| `buildCellGrid()` | Mappa colonne per navigazione verticale |
| `navigateGlobal()` | Freccia sx/dx tra righe |
| `navigateVertical()` | Freccia su/giu nella colonna |
| `handleCellInput()` | Auto-avanza dopo digitazione |
| `handleCellKeydown()` | Gestione frecce e backspace |
| `clearGrid()` | Pulisce tutti gli input |
| `showNumbers()` | Mostra operandi |
| `showResult()` | Mostra risultato |
| `verifyAnswers()` | Verifica e confetti |
| `toggleComma()` | Per virgola cliccabile |

### Navigazione con data attributes

La direzione di navigazione viene indicata dalla cella:

```html
<input data-nav-direction="ltr" ...>  <!-- left-to-right per operandi -->
<input data-nav-direction="rtl" ...>  <!-- right-to-left per risultato -->
```

## Uso

```erb
<%= render "strumenti/quaderno_grid", grid: @addizione.to_grid_matrix %>
<%= render "strumenti/quaderno_grid", grid: @divisione.to_grid_matrix %>
```
