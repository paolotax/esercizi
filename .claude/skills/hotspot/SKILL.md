# Skill: Hotspot Editor

Crea e gestisce hotspot overlay su immagini per esercizi interattivi.

---

## Tipi di Hotspot

### 1. Speech (PAROLE AL CENTRO)
Button cliccabili che pronunciano parole con sintesi vocale.
- Uso: pagine di vocabolario illustrato
- Controller: `image-speech`

### 2. Input (Esercizi)
Campi input overlay per inserire risposte.
- Uso: completare numeri, parole, operazioni
- Controller: `fill-blanks`, `auto-advance`

### 3. Textarea (Risposte Lunghe)
Campi textarea per risposte estese.
- Uso: frasi complete, pensieri
- Controller: `fill-blanks`

---

## Prompt Rapidi

### Creare Hotspot Speech
```
Crea hotspot speech per la pagina [PAGINA]
Immagine: [PATH_IMMAGINE]
Ambiente: [DESCRIZIONE]
Parole: [ELENCO_PAROLE]
Colore: [pink/blue/green/orange/purple/cyan]
```

### Creare Hotspot Input
```
Crea hotspot input per la pagina [PAGINA]
Immagine: [PATH_IMMAGINE]
Risposte: [ELENCO_RISPOSTE]
Colore: [pink/blue/green/orange/purple/cyan]
```

### Convertire Esercizio Esistente
```
Converti in hotspot l'esercizio nella pagina [FILE_ERB]
Sezione: [DESCRIZIONE_ESERCIZIO]
```

---

## Container Base

### Per Speech (PAROLE AL CENTRO) - con bordo e shadow
```erb
<div class="relative rounded-2xl overflow-hidden border-4 border-COLORE-200 shadow-2xl"
     data-controller="hotspot-editor"
     data-hotspot-editor-target="container">

  <%= image_tag "LIBRO/pNUMERO/immagine.jpg",
      alt: "Descrizione immagine",
      class: "w-full h-full object-cover select-none pointer-events-none" %>

  <div class="absolute inset-0">
    <!-- Array e loop hotspots qui -->
  </div>
</div>
```

### Per Input (Esercizi) - senza bordo e shadow
```erb
<div class="relative"
     data-controller="hotspot-editor"
     data-hotspot-editor-target="container">

  <%= image_tag "LIBRO/pNUMERO/immagine.jpg",
      alt: "Descrizione immagine",
      class: "w-full h-full object-cover select-none pointer-events-none" %>

  <div class="absolute inset-0">
    <!-- Array e loop hotspots qui -->
  </div>
</div>
```

---

## Template Speech

```erb
<% hotspots = [
  { label: "Parola1", top: "10%", left: "10%", width: "10%", height: "3.5%" },
  { label: "Parola2", top: "20%", left: "20%", width: "10%", height: "3.5%" }
] %>

<% hotspots.each do |hotspot| %>
  <button type="button"
          class="absolute rounded-xl bg-COLORE-500/10 hover:bg-COLORE-500/25 border-2 border-transparent hover:border-COLORE-500 focus:border-COLORE-600 focus:outline-none transition shadow-sm cursor-move"
          style="top: <%= hotspot[:top] %>; left: <%= hotspot[:left] %>; width: <%= hotspot[:width] %>; height: <%= hotspot[:height] %>;"
          aria-label="Leggi: <%= hotspot[:label] %>"
          data-controller="image-speech"
          data-hotspot-editor-target="hotspot"
          data-image-speech-word-value="<%= hotspot[:label] %>"
          data-image-speech-lang-value="it-IT"
          data-action="mousedown->hotspot-editor#startDrag click->image-speech#speak">
    <span class="sr-only"><%= hotspot[:label] %></span>
  </button>
<% end %>
```

---

## Template Input

```erb
<% inputs = [
  { label: "Risposta 1", top: "42%", left: "18%", width: "9%", height: "3%", answer: "1642" },
  { label: "Risposta 2", top: "57%", left: "56%", width: "13%", height: "3%", answer: "9815" }
] %>

<% inputs.each do |input| %>
  <div class="absolute"
       style="top: <%= input[:top] %>; left: <%= input[:left] %>; width: <%= input[:width] %>; height: <%= input[:height] %>;"
       data-hotspot-editor-target="hotspot"
       data-auto-advance-target="input"
       data-action="mousedown->hotspot-editor#startDrag">
    <input type="text"
           data-fill-blanks-target="input"
           data-correct-answer="<%= input[:answer] %>"
           class="w-full h-full py-2 bg-white/60 hover:bg-white/80 focus:bg-white border-2 text-black border-transparent hover:border-purple-500 focus:border-purple-600 rounded text-center font-bold text-sm transition-colors"
           maxlength="<%= input[:answer].to_s.length %>"
           inputmode="<%= input[:answer].to_s.match?(/^\d+$/) ? 'numeric' : 'text' %>"
           aria-label="<%= input[:label] %>">
  </div>
<% end %>
```

---

## Template Textarea

```erb
<% inputs = [
  { label: "Pensiero", top: "74%", left: "31%", width: "35%", height: "8%", answer: "RISPOSTA LUNGA", type: "textarea" }
] %>

<% inputs.each do |input| %>
  <div class="absolute"
       style="top: <%= input[:top] %>; left: <%= input[:left] %>; width: <%= input[:width] %>; height: <%= input[:height] %>;"
       data-hotspot-editor-target="hotspot"
       data-action="mousedown->hotspot-editor#startDrag">
    <textarea data-fill-blanks-target="input"
              data-correct-answer="<%= input[:answer] %>"
              class="w-full h-full p-2 bg-white/60 hover:bg-white/80 focus:bg-white border-2 border-transparent hover:border-purple-500 focus:border-purple-600 rounded text-center font-bold text-sm resize-none transition-colors"
              aria-label="<%= input[:label] %>"></textarea>
  </div>
<% end %>
```

---

## Template Misto (Input + Textarea)

```erb
<% inputs = [
  { label: "Num 1", top: "44%", left: "33%", width: "6%", height: "3%", answer: "424" },
  { label: "Num 2", top: "48%", left: "33%", width: "6%", height: "3%", answer: "462" },
  { label: "Pensiero", top: "74%", left: "31%", width: "35%", height: "8%", answer: "EVVIVA", type: "textarea" }
] %>

<% inputs.each do |input| %>
  <div class="absolute"
       style="top: <%= input[:top] %>; left: <%= input[:left] %>; width: <%= input[:width] %>; height: <%= input[:height] %>;"
       data-hotspot-editor-target="hotspot"
       data-action="mousedown->hotspot-editor#startDrag">
    <% if input[:type] == 'textarea' %>
      <textarea data-fill-blanks-target="input"
                data-correct-answer="<%= input[:answer] %>"
                class="w-full h-full p-2 bg-white/60 hover:bg-white/80 focus:bg-white border-2 border-transparent hover:border-purple-500 focus:border-purple-600 rounded text-center font-bold text-sm resize-none transition-colors"
                aria-label="<%= input[:label] %>"></textarea>
    <% else %>
      <input type="text"
             data-fill-blanks-target="input"
             data-correct-answer="<%= input[:answer] %>"
             class="w-full h-full py-2 bg-white/60 hover:bg-white/80 focus:bg-white border-2 text-black border-transparent hover:border-purple-500 focus:border-purple-600 rounded text-center font-bold text-sm transition-colors"
             maxlength="<%= input[:answer].to_s.length %>"
             inputmode="<%= input[:answer].to_s.match?(/^\d+$/) ? 'numeric' : 'text' %>"
             aria-label="<%= input[:label] %>">
    <% end %>
  </div>
<% end %>
```

---

## Struttura Array Hotspot

### Speech (solo visualizzazione)
```ruby
{ label: "Parola", top: "10%", left: "10%", width: "10%", height: "3.5%" }
```

### Input (esercizio)
```ruby
{ label: "Desc", top: "10%", left: "10%", width: "10%", height: "3%", answer: "42" }
```

### Textarea (risposta lunga)
```ruby
{ label: "Desc", top: "10%", left: "10%", width: "30%", height: "8%", answer: "TESTO", type: "textarea" }
```

---

## Workflow Posizionamento

### Step 1: Genera Template
Claude genera il template con coordinate placeholder (10%, 20%, etc.)

### Step 2: Vai alla Pagina
Apri la pagina nel browser (http://localhost:3000/pagine/[SLUG])

### Step 3: Attiva Edit Mode
Clicca il pulsante "Edit" in basso a destra

### Step 4: Posiziona Hotspot
- **Drag**: trascina l'hotspot nella posizione corretta
- **Resize**: usa la maniglia bianca in basso a destra

### Step 5: Copia Coordinate
Clicca "Copy" nel pannello info (in alto a destra)

### Step 6: Aggiorna Sorgente
Incolla le coordinate copiate nell'array ERB

---

## Controller Stimulus

| Controller | Scopo | Data Attributes |
|------------|-------|-----------------|
| `hotspot-editor` | Editor visuale | `data-hotspot-editor-target="container/hotspot"` |
| `image-speech` | Sintesi vocale | `data-image-speech-word-value="parola"` |
| `fill-blanks` | Verifica risposte | `data-fill-blanks-target="input"`, `data-correct-answer="X"` |
| `auto-advance` | Avanzamento auto | `data-auto-advance-target="input"` |
| `exercise-checker` | Wrapper verifica | Sul container principale |

---

## Colori Tema

| Colore | Gradient | Border | Text |
|--------|----------|--------|------|
| pink | `from-pink-50 via-white to-red-50` | `border-pink-200` | `text-pink-700` |
| blue | `from-blue-50 via-white to-blue-50` | `border-blue-200` | `text-blue-700` |
| green | `from-green-50 via-white to-green-50` | `border-green-200` | `text-green-700` |
| orange | `from-orange-50 via-white to-orange-50` | `border-orange-200` | `text-orange-700` |
| purple | `from-purple-50 via-white to-purple-50` | `border-purple-200` | `text-purple-700` |
| cyan | `from-cyan-50 via-white to-cyan-50` | `border-cyan-200` | `text-cyan-700` |

---

## Conversione Esercizi Esistenti

Per convertire un esercizio esistente in hotspot:

1. **Identifica l'immagine** di sfondo (o creane una)
2. **Estrai le risposte** dall'esercizio esistente
3. **Crea l'array inputs** con le risposte
4. **Sostituisci l'HTML** con il container hotspot + overlay
5. **Posiziona** con l'editor visuale

### Esempio Conversione

**Prima (esercizio tradizionale):**
```erb
<div class="grid grid-cols-2 gap-4">
  <input type="text" data-correct-answer="42">
  <input type="text" data-correct-answer="18">
</div>
```

**Dopo (hotspot su immagine):**
```erb
<div class="relative" data-controller="hotspot-editor" data-hotspot-editor-target="container">
  <%= image_tag "libro/pagina/esercizio.jpg", class: "w-full" %>
  <div class="absolute inset-0">
    <% inputs = [
      { label: "1", top: "40%", left: "20%", width: "10%", height: "5%", answer: "42" },
      { label: "2", top: "40%", left: "60%", width: "10%", height: "5%", answer: "18" }
    ] %>
    <!-- loop inputs -->
  </div>
</div>
```

---

## Checklist

- [ ] Container con `data-controller="hotspot-editor"`
- [ ] Container con `data-hotspot-editor-target="container"`
- [ ] Immagine con `pointer-events-none select-none`
- [ ] Ogni hotspot con `data-hotspot-editor-target="hotspot"`
- [ ] Hotspot speech: controller `image-speech` e action `click->image-speech#speak`
- [ ] Hotspot input: `data-correct-answer` e `data-fill-blanks-target="input"`
- [ ] Coordinate in percentuali (non pixel!)
- [ ] Testato drag/resize in edit mode
- [ ] Coordinate finali copiate e incollate nel sorgente

---

## Esempi Esistenti

### Speech
- `nvl5_gram_p004.html.erb` - IN BIBLIOTECA (pink)
- `nvl5_gram_p022.html.erb` - AL SUPERMERCATO (blue)
- `nvl5_gram_p040.html.erb` - IN PALESTRA (green)

### Input
- `bus3_mat_p006.html.erb` - Abachi (cyan)
- `bus3_mat_p020.html.erb` - Due pagine (cyan)
- `bus3_mat_p040.html.erb` - SAI LEGGERE NEL PENSIERO (cyan)

---

## Note Tecniche

### Opacità Edit/View Mode
- **View**: `bg-COLORE-500/10` (10% opacità)
- **Edit**: `bg-COLORE-500` (100% opacità) + bordo dotted grigio

### Label in Edit Mode
In edit mode, ogni hotspot mostra la sua label centrata per facilitare l'identificazione.

### Output Pannello Info
Il pannello mostra tutte le chiavi rilevanti:
- `label`, `top`, `left`, `width`, `height` (sempre)
- `answer` (se presente input/textarea)
- `type: "textarea"` (se textarea)
