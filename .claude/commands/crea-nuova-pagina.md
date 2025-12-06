# Crea Nuova Pagina nvi5_mat

Creare la/e pagina/e $ARGUMENTS per il libro nvi5_mat.

---

## PROCEDURA

1. **GUARDA page.png** - `assets/images/nvi5_mat/p0XX/page.png` - FONDAMENTALE per capire layout e struttura visiva!
2. **Leggi HTML originale** - `assets/images/nvi5_mat/p0XX/*.html` - per estrarre testo e risposte
3. **Cerca "Quaderno esercizi"** - Se presente nell'HTML, annota i numeri di pagina per il partial!
4. **Aggiorna seed** - Con la nuova pagina
5. **Rigenera database** - Per applicare le modifiche
6. **Analizza la struttura** - Identifica sezioni, colonne, box colorati, tipi di esercizi. CONTROLLA ANCHE le immagini jpg/png nella cartella asset della pagina per usarle nella view
7. **Identifica controller** - Quale tipo di interazione serve? (vedi sotto)
8. **Applica i pattern** - Usa i template sotto
9. **Crea la view** - `app/views/exercises/nvi5_mat_p0XX.html.erb`

---

## STRUTTURA BASE

```erb
<div class="max-w-6xl mx-auto bg-white p-3 md:p-6"
     data-controller="exercise-checker text-toggle font-controls"
     data-text-toggle-target="content"
     data-font-controls-target="content">

  <%= render 'shared/page_header', pagina: @pagina %>

  <div class="space-y-6">
    <!-- Contenuto -->
    <%= render 'shared/exercise_controls' %>
  </div>
</div>
```

---

## FONT SIZE (IMPORTANTE!)

**NON usare classi di dimensione testo fisse** come `text-xs`, `text-sm`, `text-lg`, `text-xl`, ecc.

Il controller `font-controls` gestisce la dimensione del testo dinamicamente. Se usi classi fisse, il ridimensionamento non funzionerà correttamente.

```erb
<!-- SBAGLIATO! -->
<span class="text-xl font-bold">24</span>
<p class="text-sm text-gray-600">Riassumendo:</p>

<!-- CORRETTO -->
<span class="font-bold">24</span>
<p class="text-gray-600">Riassumendo:</p>
```

---

## STILE TESTO (IMPORTANTE!)

**NON usare mai `underline`** per evidenziare il testo.

**Sottotitoli di sezione:** usare `h2` con `italic` e colore base
```erb
<h2 class="font-bold italic text-<%= @pagina.base_color %>-600">Titolo sezione</h2>
```

**Liste con marker colorati:**
```erb
<ul class="list-disc pl-6 space-y-1 text-gray-700 marker:text-<%= @pagina.base_color %>-500">
```

**Frecce:** sempre del colore base (viola/pink)
```erb
<span class="text-<%= @pagina.base_color %>-500">→</span>
```

**Testo evidenziato:** usare `text-custom-sky` (azzurro vivace)
```erb
<span class="font-bold text-custom-sky">11:15</span>
```

**Celle tabelle:** sempre bianche (non gli header)
```erb
<td class="p-2 border border-gray-300 text-center bg-white">...</td>
```

---

## BADGE ESERCIZI (IMPORTANTE!)

**Helper disponibili (usano @pagina.base_color automaticamente):**

```erb
<%= numero_esercizio_badge(N) %>           <!-- colore da @pagina.base_color -->
<%= imparare_tutti_badge(N) %>             <!-- colore da @pagina.base_color -->
```

**BADGE INLINE NEL PARAGRAFO (CORRETTO):**
```erb
<div class="mb-4">
  <p class="font-bold text-gray-700">
    <%= numero_esercizio_badge(2) %>
    Calcola il valore delle percentuali come nell'esempio.
  </p>
</div>
```

**NON USARE wrapper flex attorno al badge:**
```erb
<!-- SBAGLIATO! -->
<div class="flex items-start gap-3 mb-4">
  <%= numero_esercizio_badge(2) %>
  <p>Testo...</p>
</div>
```

---

## BOX ESERCIZI

**Container ESERCIZI (sfondo arancione):**
```erb
<div class="p-4 md:p-6 bg-orange-100 rounded-lg">
```

**Box IMPARARE TUTTI (primo esercizio evidenziato):**
```erb
<div class="p-4 bg-white rounded-2xl -mx-4 md:-mx-6 -mt-4 md:-mt-6 mb-6 border-3 border-blue-500">
  <p class="font-bold text-gray-700 mb-4">
    <%= imparare_tutti_badge(1) %>
    Consegna esercizio...
  </p>
  <!-- contenuto -->
</div>
```

**Singolo esercizio:**
```erb
<div>
  <p class="font-bold text-gray-700 mb-4">
    <%= numero_esercizio_badge(N) %>
    Consegna esercizio...
  </p>
  <!-- contenuto -->
</div>
```

---

## COLORI DINAMICI

Usare `@pagina.base_color` per colori coerenti:

```erb
<span class="text-<%= @pagina.base_color %>-700">testo esempio</span>
<div class="divide-<%= @pagina.base_color %>-300">
<div class="bg-<%= @pagina.base_color %>-50">
```

---

## COLORI CUSTOM (Tailwind 4)

| Classe | Colore | Uso |
|--------|--------|-----|
| `custom-pink` | #C657A0 | Rosa/fucsia per evidenziazioni |
| `pink-light` | #EFD9E9 | Rosa chiaro per box regole/spiegazioni |
| `custom-blue` | #C7EAFB | Celeste chiaro per sfondi |
| `custom-sky` | #0095DA | Azzurro vivace |

```erb
<div class="bg-custom-blue">sfondo celeste</div>
<span class="text-custom-pink">testo rosa</span>
<div class="border-3 border-custom-pink">bordo rosa</div>
```

---

## INPUT STANDARDIZZATI

```erb
<!-- Input dotted grigio che riempie lo spazio (per righe di risposta) -->
<div class="flex items-center gap-2">
  <input type="text" data-correct-answer="800" class="min-w-0 flex-1 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
  <span class="shrink-0">euro</span>
</div>

<!-- Input inline piccolo -->
<input type="text" data-correct-answer="120" class="w-16 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
```

**Note sugli input flex:**
- `shrink-0` sugli span di testo per evitare che si restringano
- `min-w-0 flex-1` sull'input per occupare lo spazio rimanente senza straripare

---

## PARTIAL FRAZIONE

```erb
<%= render 'shared/frazione', num: 3, den: 5 %>
<%= render 'shared/frazione', num: nil, den: 100, num_answer: "45" %>
```

---

## LAYOUT

**Due colonne con divisore:**
```erb
<div class="grid grid-cols-1 md:grid-cols-2 gap-6 md:divide-x-2 md:divide-orange-300">
  <div class="md:pr-4"><!-- Colonna sinistra --></div>
  <div class="md:pl-4"><!-- Colonna destra --></div>
</div>
```

**Griglia responsive:**
```erb
<div class="grid grid-cols-1 md:grid-cols-2 gap-3">
<div class="grid grid-cols-2 md:grid-cols-3 gap-4">
```

---

## BOX COLORATI

- **Teoria/introduzione (celeste):** `bg-custom-blue rounded-lg`
- **Regola/evidenziazione (bordo rosa):** `bg-white rounded-2xl border-3 border-custom-pink`
- **Regola/evidenziazione (bordo blu):** `bg-white rounded-2xl border-3 border-blue-400`
- **Regola/spiegazione (sfondo rosa chiaro):** `p-4 bg-pink-light rounded-3xl`
- **Esercizi:** `bg-orange-100 rounded-lg`

**Numeri grandi senza a capo:**
```erb
<span class="whitespace-nowrap">1 000</span>
```

---

## PROBLEMI TESTUALI

```erb
<div class="space-y-2">
  <p class="text-gray-700">
    <%= numero_esercizio_badge(5) %>
    Lucia ha un barattolo con 30 caramelle...
  </p>
  <div class="flex items-center gap-2">
    <input type="text" data-correct-answer="15" class="min-w-0 flex-1 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
    <span class="shrink-0">caramelle</span>
  </div>
</div>
```

---

## CHECKBOX E RADIO BUTTON

**IMPORTANTE:** `data-correct-answer` deve essere SEMPRE sull'`<input>`, MAI sulla `<label>`!

```erb
<label class="flex items-center gap-2 cursor-pointer hover:bg-gray-50 p-2 rounded border border-gray-200">
  <input type="checkbox" class="w-5 h-5" data-correct-answer="true">
  <span>Risposta corretta</span>
</label>
```

---

## ESERCIZI VERO/FALSO O SÌ/NO

**Pattern per domande V/F con box cliccabili e cambio colore:**

```erb
<div class="space-y-3">
  <div class="flex items-center justify-between gap-4 flex-wrap">
    <span class="text-gray-700"><span class="text-<%= @pagina.base_color %>-500">•</span> Testo della domanda.</span>
    <div class="flex gap-2">
      <label class="relative flex items-center justify-center w-8 h-8 bg-white border-2 border-<%= @pagina.base_color %>-500 rounded cursor-pointer hover:bg-<%= @pagina.base_color %>-100 has-checked:bg-pink-300">
        <input type="radio" name="vf1" class="absolute inset-0 opacity-0 cursor-pointer" data-correct-answer="false">
        <span>V</span>
      </label>
      <label class="relative flex items-center justify-center w-8 h-8 bg-white border-2 border-<%= @pagina.base_color %>-500 rounded cursor-pointer hover:bg-<%= @pagina.base_color %>-100 has-checked:bg-pink-300">
        <input type="radio" name="vf1" class="absolute inset-0 opacity-0 cursor-pointer" data-correct-answer="true">
        <span>F</span>
      </label>
    </div>
  </div>
</div>
```

**Caratteristiche:**
- `name="vfN"` - Ogni domanda ha un name diverso (vf1, vf2, vf3...)
- `data-correct-answer="true"` sulla risposta corretta
- Radio invisibile (`opacity-0`) ma cliccabile (`absolute inset-0`)
- Box con bordo colorato, sfondo bianco
- Hover con sfondo leggero (`hover:bg-<%= @pagina.base_color %>-100`)
- Selezione con sfondo colorato (`has-checked:bg-pink-300`)
- Bullet `•` del colore base della pagina

**Per Sì/No:** sostituire V/F con Sì/No

---

## BOX ALLENAMENTE

```erb
<div class="p-4 bg-white rounded-2xl border-3 border-blue-400">
  <p class="font-bold text-gray-800 mb-2">
    <span class="bg-yellow-400 px-2 py-1 rounded">AllenaMente!</span>
  </p>
  <p class="text-gray-700">
    Testo della consegna...
  </p>
  <!-- contenuto/immagine dentro il box -->
</div>
```

**Caratteristiche:**
- Sfondo bianco con bordo blu arrotondato
- Badge giallo per "AllenaMente!"
- Contenuto (testo e immagini) tutto dentro il box

---

## STIMULUS CONTROLLERS

**word-highlighter:** Per cerchiare/sottolineare elementi
```erb
<div data-controller="word-highlighter">
  <span data-word-highlighter-target="word" data-correct="true"
        data-action="click->word-highlighter#toggleHighlight"
        class="cursor-pointer hover:opacity-80">124</span>
</div>
```

---

## LINK AL QUADERNO (IMPORTANTE!)

**Controllare SEMPRE l'HTML originale** per la presenza di "Quaderno esercizi pp. XXX".

Se presente, aggiungere il partial **PRIMA** di `exercise_controls`:

```erb
<%= render 'shared/quaderno_link', pagine: [176, 177, 178, 183] %>

<%= render 'shared/exercise_controls' %>
```

**Formato:**
- Array di numeri di pagina: `[176, 177, 178]`
- Il partial genera automaticamente i link con il colore `@pagina.base_color`

---

## CHECKLIST FINALE

- [ ] GUARDATO page.png per capire la struttura
- [ ] Container `bg-white` + data-controllers
- [ ] Header `<%= render 'shared/page_header', pagina: @pagina %>`
- [ ] **NESSUN TITOLO h2** - Il titolo è già nel `shared/page_header`, NON duplicarlo!
- [ ] **NESSUNA classe font size** (`text-xs`, `text-sm`, `text-lg`, `text-xl`)
- [ ] Badge INLINE nel `<p>` (no wrapper flex!)
- [ ] Input flex con `min-w-0 flex-1` e `shrink-0` sugli span
- [ ] Checkbox/Radio con `data-correct-answer` su `<input>`
- [ ] Layout responsive (md:)
- [ ] **Link Quaderno** - Se nell'HTML c'è "Quaderno esercizi", aggiungi `<%= render 'shared/quaderno_link', pagine: [...] %>`
- [ ] Footer `<%= render 'shared/exercise_controls' %>`
- [ ] Seed aggiornato con la nuova pagina
- [ ] Database rigenerato
- [ ] Controllare se ci sono jpg nella cartella della pagina da usare
