# Revisione Pagine nvi5_mat

Revisionare la pagina $ARGUMENTS seguendo i pattern delle pagine 68-71.

---

## PROCEDURA

1. **GUARDA page.png** - `assets/images/nvi5_mat/p0XX/page.png` - FONDAMENTALE per capire layout e struttura visiva!
2. **Leggi HTML originale** - `assets/images/nvi5_mat/p0XX/*.html` - per estrarre testo e risposte
3. **Leggi view esistente** - `app/views/exercises/nvi5_mat_p0XX.html.erb` - se esiste
4. **Analizza la struttura** - Identifica sezioni, colonne, box colorati, tipi di esercizi
5. **Identifica controller** - Quale tipo di interazione serve? (vedi sotto)
6. **Applica i pattern** - Usa i template sotto
7. **Testa** - Verifica che la pagina funzioni

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
<div class="p-4 bg-white rounded-2xl -mx-6 -mt-6 border-3 border-blue-500">
  <div class="flex items-start lg:items-center gap-3 mb-4">
    <p class="font-bold text-gray-700">
      <%= imparare_tutti_badge(1) %>
      Consegna esercizio...
    </p>
  </div>
  <!-- contenuto -->
</div>
```

**Singolo esercizio:**
```erb
<div class="p-4 mb-6">
  <div class="mb-4">
    <p class="font-bold text-gray-700">
      <%= numero_esercizio_badge(N) %>
      Consegna esercizio...
    </p>
  </div>
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

Colori personalizzati disponibili (definiti in `@theme`):

| Classe | Colore | Uso |
|--------|--------|-----|
| `custom-pink` | #C657A0 | Rosa/fucsia per evidenziazioni |
| `pink-light` | #EFD9E9 | Rosa chiaro per box regole/spiegazioni |
| `custom-blue` | #C7EAFB | Celeste chiaro per sfondi |
| `custom-sky` | #0095DA | Azzurro vivace |
| `sky-light` | #C7EAFB | Alias per celeste chiaro |
| `custom-green` | #28A745 | Verde |
| `custom-yellow` | #FFC107 | Giallo |
| `custom-purple` | #6F42C1 | Viola |
| `custom-orange` | #FD7E14 | Arancione |
| `custom-red` | #DC3545 | Rosso |
| `custom-gray` | #6C757D | Grigio |

```erb
<div class="bg-custom-blue">sfondo celeste</div>
<span class="text-custom-pink">testo rosa</span>
<div class="border-3 border-custom-pink">bordo rosa</div>
```

---

## LISTE CON MARKER COLORATI

Per colorare i bullet delle liste usa `marker:`:

```erb
<ul class="list-disc marker:text-pink-500 ml-5">
  <li>Elemento con bullet rosa</li>
</ul>

<ul class="list-disc marker:text-custom-pink ml-5">
  <li>Elemento con bullet custom pink</li>
</ul>

<!-- Marker diversi per ogni elemento -->
<ul class="list-disc ml-5">
  <li class="marker:text-orange-700">Parentesi tonde ( )</li>
  <li class="marker:text-blue-700">Parentesi quadre [ ]</li>
  <li class="marker:text-purple-600">Parentesi graffe { }</li>
</ul>
```

---

## INPUT STANDARDIZZATI

```erb
<!-- Input numerico/testo con bordo -->
<input type="text"
       data-correct-answer="risposta"
       class="w-24 px-2 py-1 border-2 border-pink-400 rounded text-center font-bold bg-white">

<!-- Input piccolo (simboli <, >, =) -->
<input type="text"
       data-correct-answer="<"
       class="w-8 px-1 py-1 border-2 border-pink-400 rounded text-center font-bold bg-white">

<!-- Input dotted inline (per risposte in mezzo al testo) -->
<input type="text"
       data-correct-answer="120"
       class="inline w-16 border-b-2 border-dotted border-pink-400 text-center font-bold bg-transparent">

<!-- Input dotted grigio che riempie lo spazio (per righe di risposta) -->
<div class="flex items-center gap-2">
  <input type="text" data-correct-answer="800" class="min-w-0 flex-1 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
  <span class="shrink-0">euro</span>
</div>

<!-- Input con freccia pink e spazio rimanente -->
<div class="flex items-center gap-2">
  <%= render 'shared/frazione', num: 3, den: 5 %>
  <span class="shrink-0">di 250 <span class="text-custom-pink">→</span></span>
  <input type="text" data-correct-answer="150" class="min-w-0 flex-1 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
</div>
```

**Note sugli input flex:**
- `shrink-0` sugli span di testo per evitare che si restringano
- `min-w-0 flex-1` sull'input per occupare lo spazio rimanente senza straripare

---

## PARTIAL FRAZIONE

```erb
<%= render 'shared/frazione', num: 3, den: 5 %>
<%= render 'shared/frazione', num: nil, den: 100, num_answer: "45" %>
<%= render 'shared/frazione', num: nil, den: nil, num_answer: "6", den_answer: "14" %>
```

---

## LAYOUT

**Due colonne con divisore:**
```erb
<div class="grid grid-cols-1 md:grid-cols-2 divide-y-2 md:divide-y-0 md:divide-x-2 divide-<%= @pagina.base_color %>-300">
```

**Griglia responsive:**
```erb
<div class="grid grid-cols-1 md:grid-cols-2 gap-3">
<div class="grid grid-cols-2 md:grid-cols-3 gap-4">
```

**Testo + immagine:**
```erb
<div class="flex flex-col md:flex-row gap-6">
  <div class="flex-1"><!-- Testo --></div>
  <div class="flex-shrink-0"><%= image_tag "...", class: "max-w-xs" %></div>
</div>
```

---

## TITOLI

```erb
<!-- Titolo sezione con colore dinamico -->
<h2 class="font-bold text-<%= @pagina.base_color %>-600 mb-4 italic">Titolo sezione</h2>

<!-- Titolo sezione con colore custom pink -->
<h2 class="font-bold text-custom-pink mb-4 italic">Titolo sezione</h2>

<!-- Bullet istruzione -->
<p><strong><span class="text-pink-600">•</span> Istruzione</strong></p>
```

---

## BOX COLORATI

- **Teoria/introduzione (celeste):** `bg-custom-blue` oppure `bg-custom-blue rounded-lg`
- **Regola/evidenziazione (bordo rosa):** `bg-white rounded-2xl border-3 border-custom-pink`
- **Regola/evidenziazione (bordo blu):** `bg-white rounded-2xl border-3 border-blue-400`
- **Regola/spiegazione (sfondo rosa chiaro):** `p-4 bg-pink-light rounded-3xl` (colore #EFD9E9)
- **Esercizi:** `bg-orange-100 rounded-lg`
- **Divisore esercizi:** `divide-custom-pink` o `divide-<%= @pagina.base_color %>-300`
- **Esempio:** `p-3 mb-4` (senza background)

**Layout operazioni + regola (allineati):**
```erb
<div class="flex flex-col md:flex-row gap-4 items-start">
  <div class="flex-1 space-y-2">
    <p class="text-gray-700">
      25% di 15 <span class="text-pink-600">→</span>
      <%= render 'shared/frazione', num: 25, den: 100 %>
      di 15
    </p>
    <p class="text-gray-700">(15 : 100) × 25 =</p>
    <p class="text-gray-700">0,15 × 25 = 3,75 <span class="text-pink-600">← valore dello sconto</span></p>
    <p class="text-gray-700">15 − 3,75 = 11,25 <span class="text-pink-600">← prezzo scontato</span></p>
  </div>

  <div class="p-4 bg-pink-light rounded-3xl max-w-xs">
    <p class="text-gray-700">
      Chi compra un oggetto con il prezzo ribassato riceve uno <strong>sconto</strong> sul prezzo iniziale.
    </p>
  </div>
</div>
```

**Box risposta (bianco + azzurro):**
```erb
<div class="flex items-center gap-2 mt-4 flex-wrap">
  <span class="text-gray-700">Ora puoi rispondere:</span>
  <span class="p-2 bg-custom-blue rounded-lg">Stefano ha pagato il libro
    <input type="text" data-correct-answer="11,25" class="w-20 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent mx-1">
    euro e ha risparmiato
    <input type="text" data-correct-answer="3,75" class="w-20 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent mx-1">
    euro.</span>
</div>
```

**Frecce e label pink negli esempi:**
```erb
<span class="text-pink-600">→</span>
<span class="text-pink-600">← valore dello sconto</span>
```

**Numeri grandi senza a capo:**
```erb
<span class="whitespace-nowrap">1 000</span>
```

---

## PROBLEMI TESTUALI

```erb
<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <div class="mb-2">
    <p class="text-gray-700">
      <%= numero_esercizio_badge(5) %>
      Lucia ha un barattolo con 30 caramelle...
    </p>
  </div>
</div>
```

---

## CHECKBOX E RADIO BUTTON (IMPORTANTE!)

**IMPORTANTE:** `data-correct-answer` deve essere SEMPRE sull'`<input>`, MAI sulla `<label>`!

**Checkbox (risposta multipla):**
```erb
<!-- Ogni checkbox deve avere data-correct-answer="true" o "false" -->
<label class="flex items-center gap-2 cursor-pointer hover:bg-gray-50 p-2 rounded border border-gray-200">
  <input type="checkbox" class="w-5 h-5" data-correct-answer="true">
  <span>Risposta corretta</span>
</label>
<label class="flex items-center gap-2 cursor-pointer hover:bg-gray-50 p-2 rounded border border-gray-200">
  <input type="checkbox" class="w-5 h-5" data-correct-answer="false">
  <span>Risposta sbagliata</span>
</label>
```

**Radio button (scelta singola):**
```erb
<!-- Solo la risposta corretta ha data-correct-answer="true" -->
<div class="inline-flex border border-gray-400 rounded overflow-hidden">
  <label class="px-3 py-1 cursor-pointer hover:bg-gray-100 border-r border-gray-400">
    <input type="radio" name="domanda1" value="si" class="mr-1">Sì
  </label>
  <label class="px-3 py-1 cursor-pointer hover:bg-gray-100">
    <input type="radio" name="domanda1" value="no" data-correct-answer="true" class="mr-1">No
  </label>
</div>
```

**ERRORI COMUNI DA EVITARE:**
```erb
<!-- SBAGLIATO! data-correct sulla label -->
<label data-correct="true">
  <input type="checkbox">
</label>

<!-- SBAGLIATO! data-correct-answer="si" o "no" -->
<input type="radio" data-correct-answer="si">

<!-- CORRETTO -->
<input type="checkbox" data-correct-answer="true">
<input type="radio" data-correct-answer="true">
```

---

## STIMULUS CONTROLLERS

**svg-colorable:** Per colorare figure
```erb
<div data-controller="svg-colorable" data-svg-colorable-color-value="#ffc0cb">
  <path data-svg-colorable-target="cell" data-action="click->svg-colorable#toggleCell"/>
</div>
```

**word-highlighter:** Per cerchiare/sottolineare elementi
```erb
<!-- Monocolor: data-correct="true" o "false" -->
<div data-controller="word-highlighter">
  <span data-word-highlighter-target="word" data-correct="true"
        data-action="click->word-highlighter#toggleHighlight"
        class="cursor-pointer hover:opacity-80">124</span>
  <span data-word-highlighter-target="word" data-correct="false"
        data-action="click->word-highlighter#toggleHighlight"
        class="cursor-pointer hover:opacity-80">107</span>
</div>

<!-- Multicolor: data-correct è il nome colore (red, green, blue, ecc.) -->
<div data-controller="word-highlighter" data-word-highlighter-multi-color-value="true">
  <span data-word-highlighter-target="word" data-correct="green"
        data-action="click->word-highlighter#toggleHighlight"
        class="cursor-pointer hover:opacity-80">parola</span>
</div>
```

**equivalent-fractions:** Per frazioni equivalenti
```erb
<div data-controller="equivalent-fractions">
  <div data-equivalent-fractions-target="fractionGroup" data-original-num="4" data-original-den="9">
```

**flower-matcher:** Per collegare elementi
```erb
<div data-controller="flower-matcher">
  <div data-action="click->flower-matcher#selectFlower"
       data-flower-matcher-target="flower"
       data-flower-id="top-1"
       data-pair="a">
```

---

## CHECKLIST

- [ ] GUARDATO page.png per capire la struttura
- [ ] Container `bg-white` + data-controllers
- [ ] Header `<%= render 'shared/page_header', pagina: @pagina %>`
- [ ] Badge con `numero_esercizio_badge(N)` INLINE nel `<p>` (no wrapper flex!)
- [ ] Badge IMPARARE TUTTI con `imparare_tutti_badge(N)` se presente
- [ ] Colori dinamici con `@pagina.base_color`
- [ ] Input con `border-2 border-pink-400`
- [ ] Checkbox/Radio con `data-correct-answer` su `<input>` (mai su label!)
- [ ] Frazioni con partial `shared/frazione`
- [ ] Layout responsive (md:)
- [ ] Box colorati corretti
- [ ] Controller Stimulus appropriati
- [ ] Footer `<%= render 'shared/exercise_controls' %>`
