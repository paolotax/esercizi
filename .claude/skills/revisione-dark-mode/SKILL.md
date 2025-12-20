---
name: revisione-dark-mode
description: Revisiona pagine bus3_mat da p056 in poi per dark mode e converte esercizi ripetitivi ai partial fill_item/fill_list
---

# Skill: Revisione Dark Mode e Conversione Fill Partials

Revisiona pagine bus3_mat da p056 in poi per supporto dark mode completo e converte esercizi ripetitivi ai partial `fill_item`/`fill_list`.

---

## Quando Usare

Usa questo skill per:
- Aggiungere supporto dark mode a pagine bus3_mat da p056 a p192
- Convertire esercizi con input HTML ripetitivi ai partial standardizzati
- Uniformare lo stile delle pagine al pattern dark mode del progetto

---

## Checklist Dark Mode

### 1. Container Principale

```erb
<%# PRIMA %>
<div class="max-w-7xl mx-auto p-3 md:p-6 bg-white"

<%# DOPO %>
<div class="max-w-7xl mx-auto p-3 md:p-6 bg-white dark:bg-gray-900 text-black dark:text-white transition-colors duration-300"
```

### 2. Testi

| Prima | Dopo |
|-------|------|
| `text-gray-700` | `text-gray-700 dark:text-gray-200` |
| `text-gray-600` | `text-gray-600 dark:text-gray-400` |
| `text-gray-800` | `text-gray-800 dark:text-gray-200` |
| (nessuna classe testo) | aggiungi `dark:text-white` |

### 3. Box Colorati

| Colore | Prima | Dopo |
|--------|-------|------|
| Azzurro | `bg-[#C7EAFB]` | `bg-[#C7EAFB] dark:bg-cyan-900/40` |
| Rosa | `bg-[#FFE4E1]` | `bg-[#FFE4E1] dark:bg-pink-900/30` |
| Giallo | `bg-[#FFF9E6]` | `bg-[#FFF9E6] dark:bg-yellow-900/30` |
| Verde | `bg-[#E8F5E9]` | `bg-[#E8F5E9] dark:bg-green-900/30` |
| Arancione | `bg-orange-100` | `bg-orange-100 dark:bg-orange-900/30` |
| Bianco interno | `bg-white` | `bg-white dark:bg-gray-800` |
| Cyan | `bg-cyan-100` | `bg-cyan-100 dark:bg-cyan-900/50` |
| Pink | `bg-pink-100` | `bg-pink-100 dark:bg-pink-900/50` |

### 4. Bordi

| Prima | Dopo |
|-------|------|
| `border-cyan-300` | `border-cyan-300 dark:border-cyan-500` |
| `border-cyan-400` | `border-cyan-400 dark:border-cyan-500` |
| `border-gray-400` | `border-gray-400 dark:border-gray-500` |
| `border-pink-400` | `border-pink-400 dark:border-pink-500` |
| `border-orange-400` | `border-orange-400 dark:border-orange-500` |

### 5. Link

```erb
<%# PRIMA %>
<%= link_to "p. 154", pagina_path("..."), class: "text-cyan-600 font-bold hover:underline" %>

<%# DOPO %>
<%= link_to "p. 154", pagina_path("..."), class: "text-cyan-600 dark:text-cyan-400 font-bold hover:underline" %>
```

### 6. Immagini (Box Bianco per Dark Mode)

**IMPORTANTE**: Tutte le immagini JPG/PNG devono essere wrappate in un container con sfondo bianco visibile solo in dark mode. Questo garantisce che le immagini con sfondo trasparente o chiaro siano visibili.

#### Pattern Standard - Immagine Centrata

```erb
<%# PRIMA %>
<div class="mb-6">
  <%= image_tag "esercizio.jpg",
      alt: "Descrizione",
      class: "w-full h-auto max-w-4xl mx-auto" %>
</div>

<%# DOPO %>
<div class="mb-6 flex justify-center">
  <div class="dark:bg-white rounded-xl p-1">
    <%= image_tag "esercizio.jpg",
        alt: "Descrizione",
        class: "w-full h-auto max-w-4xl rounded-lg" %>
  </div>
</div>
```

#### Pattern - Immagine in Card/Box

```erb
<%# PRIMA %>
<div class="bg-white dark:bg-gray-800 rounded-lg p-4">
  <div class="flex justify-center mb-4">
    <%= image_tag "figura.png", class: "w-48 h-auto" %>
  </div>
</div>

<%# DOPO %>
<div class="bg-white dark:bg-gray-800 rounded-lg p-4">
  <div class="flex justify-center mb-4">
    <div class="dark:bg-white rounded-xl p-1">
      <%= image_tag "figura.png", class: "w-48 h-auto rounded-lg" %>
    </div>
  </div>
</div>
```

#### Pattern - Immagine Piccola Inline

```erb
<%# Per immagini piccole in linea con testo %>
<div class="dark:bg-white rounded-lg p-1 inline-block">
  <%= image_tag "icona.png", class: "h-8 w-auto" %>
</div>
```

#### Checklist Immagini

| Elemento | Classe |
|----------|--------|
| Container wrapper | `dark:bg-white rounded-xl p-1` |
| Immagine grande | aggiungi `rounded-lg` alla classe immagine |
| Container esterno | aggiungi `flex justify-center` se l'immagine deve essere centrata |
| Rimuovi `mx-auto` | sposta il centramento al container esterno |

**Nota**: Il wrapper usa `dark:bg-white` quindi è trasparente in light mode e bianco in dark mode. Il `rounded-xl p-1` crea un bordo arrotondato con piccolo padding.

### 7. Input Manuali (se non convertiti a partial)

```erb
<%# PRIMA %>
<input type="text" class="w-14 px-1 py-1 border-b-2 border-dotted border-gray-400 text-center font-bold"

<%# DOPO %>
<input type="text" class="w-14 px-1 py-1 border-b-2 border-dotted border-gray-400 dark:border-gray-500 bg-transparent dark:text-white text-center font-bold"
```

---

## Conversione a Fill Partials

### Quando Convertire

**Converti a `fill_list` quando:**
- Ci sono 3+ input simili in sequenza verticale
- Ogni riga ha struttura: `testo + input` o `testo + input + testo`
- Gli input hanno pattern ripetitivo (stesse classi, stesso layout)

**Converti a `fill_item` quando:**
- C'è un singolo input con prefix/suffix
- La frase è complessa con input nel mezzo

### Quando NON Convertire

- Input in tabelle con struttura complessa
- Divisioni in colonna (layout tabellare specifico)
- Hotspot su immagini
- Input con posizionamento assoluto
- Griglie CSS dove il posizionamento è critico

---

## Parametri Partial

### fill_item

```ruby
# Tutti i parametri disponibili
answer: "risposta"      # Risposta corretta (obbligatorio se c'è input)
prefix: "testo prima"   # Testo prima dell'input
suffix: "testo dopo"    # Testo dopo l'input
arrow: true/false       # Mostra freccia "→"
equals: true/false      # Mostra "="
unit: "km"              # Unità di misura dopo input
width: "w-20"           # Classe Tailwind larghezza (auto se omesso)
bullet: "a."            # Punto elenco
color: "cyan"           # Colore bordo (default "gray")
inputmode: "numeric"    # Tipo tastiera (auto-detect se omesso)
maxlength: 5            # Lunghezza massima (auto se omesso)
segments: [...]         # Array per frasi complesse (vedi sotto)
flex: true/false        # Input flex-grow
```

### fill_list

```ruby
# Tutti i parametri disponibili
items: [...]                    # Array di hash (ogni hash = parametri fill_item)
color: "cyan"                   # Default per tutti gli item
bullet: nil                     # Default bullet
arrow: false                    # Default arrow
equals: false                   # Default equals
width: nil                      # Default width
unit: nil                       # Default unit
flex: false                     # Default flex
container_class: "space-y-2"    # Classe container div
```

---

## Modalità Segments

Per frasi con input nel mezzo o strutture complesse:

```erb
<%= render 'shared/fill_item',
    color: "cyan",
    segments: [
      "Se aggiungi",                    # Stringa = testo
      { answer: "1" },                  # Hash con answer = input
      "a un numero, trovi il suo successivo."
    ] %>
```

**Tipi di elementi in segments:**
- `"stringa"` - Testo semplice
- `{ answer: "X" }` - Input con risposta
- `{ answer: "X", width: "w-20" }` - Input con larghezza custom
- `{ text: "testo" }` - Testo esplicito
- `{ html: "<strong>bold</strong>" }` - HTML raw

---

## Esempi di Conversione

### Esempio 1: Lista semplice prefix + input

**PRIMA:**
```erb
<div class="space-y-4" data-controller="fill-blanks">
  <div class="flex items-center gap-2">
    <span>48 : 4 =</span>
    <input type="text" data-fill-blanks-target="input" data-correct-answer="12"
           class="w-14 px-1 py-1 border-b-2 border-dotted border-gray-400 text-center font-bold"
           maxlength="2" inputmode="numeric">
  </div>
  <div class="flex items-center gap-2">
    <span>81 : 2 =</span>
    <input type="text" data-fill-blanks-target="input" data-correct-answer="40"
           class="w-14 px-1 py-1 border-b-2 border-dotted border-gray-400 text-center font-bold"
           maxlength="2" inputmode="numeric">
    <span>r 1</span>
  </div>
</div>
```

**DOPO:**
```erb
<%= render 'shared/fill_list',
    color: "cyan",
    items: [
      { prefix: "48 : 4 =", answer: "12" },
      { prefix: "81 : 2 =", answer: "40", suffix: "r 1" }
    ] %>
```

### Esempio 2: Con freccia e uguale

**PRIMA:**
```erb
<div class="flex items-center gap-2">
  <span>5 h</span>
  <span>=</span>
  <input type="text" data-correct-answer="50" class="w-14 ...">
  <span>da</span>
</div>
```

**DOPO:**
```erb
<%= render 'shared/fill_list',
    color: "cyan",
    equals: true,
    items: [
      { prefix: "5 h", answer: "50", unit: "da" }
    ] %>
```

### Esempio 3: Pattern con segments

**PRIMA:**
```erb
<div class="flex items-center gap-2">
  <span>16 + 121</span>
  <span>=</span>
  <input type="text" data-correct-answer="121 + 16" class="w-28 ...">
  <span>=</span>
  <input type="text" data-correct-answer="137" class="w-14 ...">
</div>
```

**DOPO:**
```erb
<%= render 'shared/fill_list',
    color: "cyan",
    items: [
      { segments: ["16 + 121", "=", { answer: "121 + 16", width: "w-28" }, "=", { answer: "137" }] }
    ] %>
```

### Esempio 4: Frase con input nel mezzo

**PRIMA:**
```erb
<p>Se aggiungi <input type="text" data-correct-answer="1" class="w-12 ..."> a un numero, trovi il suo successivo.</p>
```

**DOPO:**
```erb
<%= render 'shared/fill_item',
    color: "cyan",
    segments: ["Se aggiungi", { answer: "1" }, "a un numero, trovi il suo successivo."] %>
```

### Esempio 5: Grid di operazioni

**PRIMA:**
```erb
<div class="grid grid-cols-2 gap-4" data-controller="fill-blanks">
  <div class="flex items-center gap-2">
    <span>12 × 3 =</span>
    <input type="text" data-correct-answer="36" class="...">
  </div>
  <div class="flex items-center gap-2">
    <span>15 × 4 =</span>
    <input type="text" data-correct-answer="60" class="...">
  </div>
</div>
```

**DOPO:**
```erb
<%= render 'shared/fill_list',
    color: "cyan",
    container_class: "grid grid-cols-2 gap-4",
    items: [
      { prefix: "12 × 3 =", answer: "36" },
      { prefix: "15 × 4 =", answer: "60" }
    ] %>
```

---

## Pattern da Riconoscere

### Pattern 1: Input in lista verticale
```html
<div class="space-y-N">
  <div>...<input>...</div>
  <div>...<input>...</div>
  <div>...<input>...</div>
</div>
```
→ Converti a `fill_list`

### Pattern 2: Grid di operazioni semplici
```html
<div class="grid grid-cols-N">
  <div><span>op =</span><input></div>
  <div><span>op =</span><input></div>
</div>
```
→ Converti a `fill_list` con `container_class: "grid grid-cols-N gap-4"`

### Pattern 3: Frase con blank
```html
<p>Testo <input> altro testo.</p>
```
→ Converti a `fill_item` con `segments`

### Pattern 4: Operazioni con unità
```html
<span>5 h =</span><input><span>da</span>
```
→ Converti a `fill_item` con `prefix`, `answer`, `unit`

---

## Workflow per Processare una Pagina

### Step 1: Apertura e Analisi
1. Leggi il file ERB completo
2. Identifica se manca il dark mode (cerca `bg-white` senza `dark:bg-gray-900`)
3. Identifica esercizi con input ripetitivi candidati alla conversione

### Step 2: Aggiungi Dark Mode
1. Modifica il container principale (aggiungi `dark:bg-gray-900 text-black dark:text-white`)
2. Aggiungi varianti dark ai box colorati
3. Aggiungi varianti dark ai testi (`dark:text-gray-200`)
4. Aggiungi varianti dark ai bordi
5. Aggiungi varianti dark ai link
6. **Wrappa TUTTE le immagini** nel box bianco (`dark:bg-white rounded-xl p-1`)

### Step 3: Valuta Conversione Input
Per ogni sezione con input:
1. Conta gli input simili
2. Verifica se il pattern è riproducibile con fill_list/fill_item
3. Se sì: converti. Se no: aggiungi solo dark mode agli input

### Step 4: Conversione (se applicabile)
1. Identifica il pattern (lista, griglia, frase)
2. Estrai le risposte corrette (`data-correct-answer`)
3. Costruisci l'array items
4. Sostituisci HTML con il partial render
5. Rimuovi il `data-controller="fill-blanks"` dal container (il partial lo include)

### Step 5: Verifica
1. Controlla che non ci siano classi senza variante dark
2. Verifica che i partial siano renderizzati correttamente
3. Esegui `bin/rails tailwindcss:build` per compilare CSS

---

## Riferimenti

### Pagine Esempio con Dark Mode Completo
- `bus3_mat_p024.html.erb` - Usa fill_list e fill_item
- `bus3_mat_p052.html.erb` - Box colorati con dark mode
- `bus3_mat_p053.html.erb` - Input con dark mode
- `bus3_mat_p054.html.erb` - Layout griglia con dark mode
- `bus3_mat_p055.html.erb` - Dark mode completo

### Partial di Riferimento
- `/app/views/shared/_fill_item.html.erb`
- `/app/views/shared/_fill_list.html.erb`

### Pagine Target
```
bus3_mat_p056.html.erb -> bus3_mat_p192.html.erb
```
