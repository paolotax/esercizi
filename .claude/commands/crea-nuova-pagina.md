# Crea Nuova Pagina nvi4_mat

Creare la/e pagina/e $ARGUMENTS per il libro nvi4_mat.

---

## PROCEDURA

1. **GUARDA page.png** - `assets/images/nvi4_mat/p0XX/page.png` - FONDAMENTALE per capire layout e struttura visiva!
2. **Leggi HTML originale** - `assets/images/nvi4_mat/p0XX/*.html` - per estrarre testo e risposte
3. **Cerca "Quaderno esercizi"** - Se presente nell'HTML, annota i numeri di pagina per il partial!
4. **Aggiorna seed** - Con la nuova pagina
5. **Rigenera database** - Per applicare le modifiche
6. **Analizza la struttura** - Identifica sezioni, colonne, box colorati, tipi di esercizi. CONTROLLA ANCHE le immagini jpg/png nella cartella asset della pagina per usarle nella view
7. **Identifica controller** - Quale tipo di interazione serve? (vedi sotto)
8. **Applica i pattern** - Usa i template sotto
9. **Crea la view** - `app/views/exercises/nvi4_mat_p0XX.html.erb`

---

## STRUTTURA BASE

```erb
<div class="max-w-6xl mx-auto bg-white dark:bg-gray-900 p-3 md:p-6 transition-colors duration-300"
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
<div class="p-4 md:p-6 bg-orange-100 rounded-2xl">
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

## STILI CORRETTI (IMPORTANTE!)

**Rosa per box regole/spiegazioni:**
- ✅ CORRETTO: `bg-pink-light` (#EFD9E9)
- ❌ SBAGLIATO: `bg-pink-50`, `bg-pink-100`

**Header tabelle valori posizionali:**
- ✅ CORRETTO: `bg-custom-blue-light` con testo colorato (text-red-600, text-blue-600, text-green-600)
- ❌ SBAGLIATO: `bg-cyan-100`

**Tabelle standard:**
- Bordi tabella e celle: `border-2 border-cyan-400`
- Header celle: `bg-custom-blue-light`

**Box teoria importante:**
- ✅ CORRETTO: `bg-white rounded-3xl border-4 border-blue-800`

**Tabelle combinazioni (es. astucci/colori):**
- Celle: `border-2 border-cyan-400`
- Header colorati: `bg-pink-400`, `bg-green-500`, `bg-cyan-500` con `text-white`
- Prima cella angolo: `border-t-transparent border-l-transparent`

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

## PARTIAL OPERAZIONI INVERSE

Per diagrammi con frecce che mostrano operazioni inverse (moltiplicazione/divisione):

```erb
<%= render 'shared/operazioni_inverse',
    left: 12, right: 36,
    op_direct: "×", op_direct_num: 3,
    op_inverse: ":", op_inverse_num: 3 %>
```

**Con input (numero da trovare):**
```erb
<%= render 'shared/operazioni_inverse',
    left: nil, left_answer: "9", right: 45,
    op_direct: "×", op_direct_num: 5,
    op_inverse: ":", op_inverse_num: 5 %>
```

**Parametri:**
- `left`, `right`: numeri nei box (nil per input)
- `left_answer`, `right_answer`: risposta se il numero è nil
- `op_direct`: operatore diretto (×, :, +, -)
- `op_direct_num`: numero operazione (o nil per input)
- `op_inverse`: operatore inverso
- `op_inverse_num`: numero operazione inversa

**Colori automatici:** × e + = blu, : e - = arancione

**Centrare il partial:**
```erb
<div class="flex justify-center">
  <%= render 'shared/operazioni_inverse', ... %>
</div>
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

**Layout problema + diagramma (risposta allineata in basso):**
```erb
<div class="p-4 md:p-6">
  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <div>
      <div class="p-3 bg-custom-blue-light mb-4">
        <p class="text-gray-700">Testo del problema...</p>
      </div>
      <div class="flex justify-center">
        <%= render 'shared/operazioni_inverse', ... %>
      </div>
    </div>
    <div class="flex flex-col justify-end">
      <div class="p-3">
        <p class="text-gray-700 font-bold">45 : 5 = 9</p>
        <p class="text-gray-700">Risposta al problema.</p>
      </div>
    </div>
  </div>
</div>
```

**Caratteristiche:**
- Problema in box azzurro (bg-custom-blue-light, NO rounded)
- Diagramma centrato sotto il problema
- Risposta allineata in basso (`justify-end`) senza bordo

---

## BOX COLORATI

### Sezioni teoria (contenitori generici)
Sfondo BIANCO (nessun bg), solo padding:
```erb
<div class="p-4 md:p-6">
  <!-- contenuto teoria -->
</div>
```

### Problema/quesito testuale (azzurro, NO rounded)
Per problemi da risolvere, quesiti:
```erb
<div class="p-3 bg-custom-blue-light">
  <p class="text-gray-700">Testo del problema...</p>
</div>
```

### Regola breve (rosa chiaro, arrotondato)
Per regole e definizioni brevi:
```erb
<div class="p-3 bg-pink-light rounded-2xl w-fit">
  <p class="text-gray-700">Regola o definizione...</p>
</div>
```

Variante per regole comportamento:
```erb
<div class="p-3 bg-pink-light rounded-xl w-fit">
  <p class="text-gray-600">Regola comportamento...</p>
</div>
```

### Box teoria importante (bordo blu, arrotondato)
Per concetti fondamentali con bordo:
```erb
<div class="p-4 md:p-6 bg-white rounded-2xl border-3 border-blue-800">
  <!-- contenuto importante -->
</div>
```

### Container esercizi (arancione, arrotondato)
```erb
<div class="p-4 md:p-6 bg-orange-100 rounded-2xl">
  <!-- esercizi -->
</div>
```

**Numeri grandi senza a capo:**
```erb
<span class="whitespace-nowrap">1 000</span>
```

---

## BOX TEORIA IMPORTANTE (REGOLE FONDAMENTALI)

Per box che contengono regole importanti, definizioni fondamentali o concetti chiave:

```erb
<div class="p-4 md:p-6 bg-white rounded-2xl border-3 border-blue-800 space-y-4">
  <!-- contenuti SENZA bg/border/rounded -->
  <div>
    <p class="text-gray-700">
      <span class="text-<%= @pagina.base_color %>-500">●</span>
      Prima regola o concetto...
    </p>
  </div>
  <div>
    <p class="text-gray-700">
      <span class="text-<%= @pagina.base_color %>-500">●</span>
      Seconda regola...
    </p>
  </div>
</div>
```

**Caratteristiche:**
- Sfondo bianco con bordo blu scuro (`border-3 border-blue-800`)
- Bordi arrotondati (`rounded-2xl`)
- I contenuti interni NON hanno bg/border/rounded

---

## TABELLE "SIGNIFICA..." (SCOMPOSIZIONE NUMERI)

Per tabelle che spiegano il significato/scomposizione dei numeri (es. "23 significa...", "386 significa..."):

```erb
<div class="bg-white overflow-hidden border-2 border-cyan-400">
  <table class="w-full border-collapse">
    <tbody>
      <tr class="border-b-2 border-cyan-400">
        <td class="p-3 text-gray-700 border-r-2 border-cyan-400">
          <span class="font-bold text-cyan-600">23</span> significa
        </td>
        <td class="p-3 text-center border-r-2 border-cyan-400">
          <span class="font-bold text-cyan-600">2</span> volte <span class="font-bold text-cyan-600">dieci</span>
        </td>
        <td class="p-3 text-center border-r-2 border-cyan-400">+</td>
        <td class="p-3 text-center border-r-2 border-cyan-400">
          <span class="font-bold text-cyan-600">3</span> volte <span class="font-bold text-cyan-600">uno</span>
        </td>
        <td class="p-3 text-gray-500"></td>
      </tr>
      <tr class="border-b-2 border-cyan-400">
        <td class="p-3 text-gray-700 border-r-2 border-cyan-400">si può scrivere</td>
        <td class="p-3 text-center border-r-2 border-cyan-400 font-bold text-cyan-600">2 × 10</td>
        <td class="p-3 text-center border-r-2 border-cyan-400">+</td>
        <td class="p-3 text-center border-r-2 border-cyan-400 font-bold text-cyan-600">3 × 1</td>
        <td class="p-3 text-gray-500">somma di prodotti</td>
      </tr>
      <!-- altre righe... -->
    </tbody>
  </table>
</div>
```

**Caratteristiche:**
- Bordo esterno e celle: `border-2 border-cyan-400`
- Testo evidenziato: `text-cyan-600` (NON base_color)
- Nessun rounded sul container

---

## CONTENUTI DENTRO CONTAINER ESERCIZI

**IMPORTANTE:** I div interni al container esercizi (`bg-orange-100` o `bg-white`) NON devono avere:
- `bg-white` o altri sfondi
- `border` o `border-gray-200`
- `rounded-lg` o altri rounded

```erb
<!-- CORRETTO -->
<div class="p-4 md:p-6 bg-orange-100 rounded-lg">
  <div class="mb-8">
    <p class="font-bold text-gray-700 mb-4">...</p>
    <div class="space-y-3">
      <!-- contenuti senza styling box -->
    </div>
  </div>
</div>

<!-- SBAGLIATO -->
<div class="p-4 md:p-6 bg-orange-100 rounded-lg">
  <div class="bg-white p-4 rounded-lg border border-gray-200">
    <!-- NO! I contenuti non devono avere bg/border/rounded -->
  </div>
</div>
```

---

## TABELLA CLASSI/ORDINI (BICOLORE)

Per tabelle con due sezioni colorate (es. Classe delle Migliaia vs Classe delle Unità):

```erb
<table class="w-full border-collapse">
  <!-- Header classi -->
  <tr>
    <th colspan="3" class="p-2 bg-<%= @pagina.base_color %>-500 text-white border-2 border-<%= @pagina.base_color %>-500 font-bold">
      CLASSE DELLE MIGLIAIA
    </th>
    <th colspan="3" class="p-2 bg-cyan-500 text-white border-2 border-cyan-500 font-bold">
      CLASSE DELLE UNITÀ SEMPLICI
    </th>
  </tr>
  <!-- Sottotitoli ordini (bg-XXX-100) -->
  <tr>
    <td class="p-2 border-2 border-<%= @pagina.base_color %>-400 text-center bg-<%= @pagina.base_color %>-100">
      ordine delle centinaia di migliaia
    </td>
    <!-- ... altre celle base_color ... -->
    <td class="p-2 border-2 border-cyan-400 text-center bg-cyan-100">
      ordine delle centinaia
    </td>
    <!-- ... altre celle cyan ... -->
  </tr>
  <!-- Abbreviazioni (bg-XXX-50, colori bicolore per unità) -->
  <tr>
    <td class="p-2 border-2 border-<%= @pagina.base_color %>-400 text-center bg-<%= @pagina.base_color %>-50 font-bold text-red-600">hk</td>
    <td class="p-2 border-2 border-<%= @pagina.base_color %>-400 text-center bg-<%= @pagina.base_color %>-50 font-bold text-blue-600">dak</td>
    <td class="p-2 border-2 border-<%= @pagina.base_color %>-400 text-center bg-<%= @pagina.base_color %>-50 font-bold text-green-600">uk</td>
    <td class="p-2 border-2 border-cyan-400 text-center bg-cyan-50 font-bold text-red-600">h</td>
    <td class="p-2 border-2 border-cyan-400 text-center bg-cyan-50 font-bold text-blue-600">da</td>
    <td class="p-2 border-2 border-cyan-400 text-center bg-cyan-50 font-bold text-green-600">u</td>
  </tr>
  <!-- Valori (bg-white) -->
  <tr>
    <td class="p-2 border-2 border-<%= @pagina.base_color %>-400 text-center bg-white">100 000</td>
    <!-- ... -->
  </tr>
</table>
```

**Pattern sfondi graduali:**
- Header: `bg-XXX-500 text-white`
- Sottotitoli: `bg-XXX-100`
- Abbreviazioni: `bg-XXX-50`
- Valori: `bg-white`

**Colori unità di misura (BICOLORE):**
- Centinaia (h, hk): `text-red-600`
- Decine (da, dak): `text-blue-600`
- Unità (u, uk): `text-green-600`

---

## ABACO PARTIAL

Per visualizzare numeri su abaco (non modificabile):

```erb
<div class="flex justify-center">
  <%= render 'strumenti/abaco/abaco',
      **Abaco.new(
        number: 386,
        h: 3,
        da: 8,
        u: 6,
        editable: false,
        show_value: false
      ).to_partial_params %>
</div>
```

**Parametri:**
- `number`: il numero da rappresentare
- `h`, `da`, `u`: cifre per centinaia, decine, unità
- `editable: false`: non modificabile dall'utente
- `show_value: false`: nasconde il valore numerico sotto l'abaco

---

## RIEPILOGO BOX E CONTAINER

| Tipo | Sfondo | Bordo | Rounded | Uso |
|------|--------|-------|---------|-----|
| **Sezioni Teoria** | nessuno | nessuno | nessuno | Contenitore generico (sfondo bianco pagina) |
| **Problema/quesito** | bg-custom-blue-light | nessuno | nessuno | Problemi da risolvere |
| **Regola breve** | bg-pink-light w-fit | nessuno | rounded-2xl | Regole/definizioni |
| **Box Teoria Importante** | bg-white | border-3 border-blue-800 | rounded-2xl | Regole fondamentali |
| **Tabelle Significato Numeri** | bg-white | border-2 border-cyan-400 | nessuno | "23 significa..." |
| **Container Esercizi** | bg-orange-100 | nessuno | rounded-2xl | Wrapper esercizi |
| **Contenuti Esercizi** | nessuno | nessuno | nessuno | Dentro container |
| **Box IMPARARE TUTTI** | bg-white | border-3 border-blue-500 | rounded-2xl | Primo esercizio |
| **Box AllenaMente** | bg-white | border-3 border-blue-400 | rounded-2xl | Sfida finale |

---

## PROBLEMI TESTUALI

**IMPORTANTE:** I problemi devono essere RISOLTI. Inserisci sempre il `data-correct-answer` con la risposta corretta calcolata.

**Input allineato a destra:**
```erb
<div class="space-y-2">
  <p class="text-gray-700">
    <%= numero_esercizio_badge(5) %>
    Lucia ha un barattolo con 30 caramelle. Ne mangia la metà. Quante caramelle restano?
  </p>
  <div class="flex items-center justify-end gap-2">
    <input type="text" data-correct-answer="15" class="min-w-0 flex-1 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
    <span class="shrink-0">caramelle</span>
  </div>
</div>
```

**Caratteristiche:**
- `justify-end` allinea input e unità a destra
- `min-w-0 flex-1` input che si adatta allo spazio disponibile
- `data-correct-answer="15"` con la risposta CALCOLATA (30 ÷ 2 = 15)
- `shrink-0` sull'unità di misura per evitare che si comprima

**Problema con più risposte (più righe):**
```erb
<div class="space-y-2">
  <p class="text-gray-700">
    <%= numero_esercizio_badge(6) %>
    Marco ha 24 figurine e le divide in 4 album uguali. Quante figurine mette in ogni album? Quante ne restano?
  </p>
  <div class="flex items-center justify-end gap-2">
    <span class="shrink-0">Figurine per album:</span>
    <input type="text" data-correct-answer="6" class="min-w-0 flex-1 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
  </div>
  <div class="flex items-center justify-end gap-2">
    <span class="shrink-0">Figurine restanti:</span>
    <input type="text" data-correct-answer="0" class="min-w-0 flex-1 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
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

## CONTROLLER MATEMATICA

**Operazioni in colonna:**
```erb
data-controller="column-addition"      <!-- Addizioni in colonna -->
data-controller="column-subtraction"   <!-- Sottrazioni in colonna -->
data-controller="column-multiplication" <!-- Moltiplicazioni in colonna -->
```

**Partial operazioni:**
```erb
<%= render 'strumenti/sottrazioni/column_subtraction',
    sottrazione: Sottrazione.new(minuend: 532, subtrahend: 175,
      show_minuend_subtrahend: true, show_solution: false,
      show_borrow: true, show_toolbar: false) %>

<%= render 'strumenti/addizioni/column_addition',
    addizione: Addizione.new(addends: [234, 567],
      show_addends: true, show_solution: false,
      show_carry: true, show_toolbar: false) %>
```

**Abaco:**
```erb
data-controller="abaco"
<%= render 'strumenti/abaco/abaco', **Abaco.new(number: 386, editable: false).to_partial_params %>
```

**Frazioni:**
```erb
data-controller="fraction-coloring"    <!-- Colorare parti di figura -->
data-controller="fraction-circles"     <!-- Cerchi frazionati -->
data-controller="fraction-grids"       <!-- Griglie frazionate -->
data-controller="equivalent-fractions" <!-- Frazioni equivalenti -->
```

**Selezione/evidenziazione:**
```erb
data-controller="word-highlighter"     <!-- Cerchiare/sottolineare parole -->
data-controller="clickable-choice"     <!-- Scelte cliccabili -->
```

**Linea dei numeri:**
```erb
data-controller="number-line"
```

**Proprietà operazioni:**
```erb
<%= render 'shared/commutativa', a: 8, b: 2, result: :auto, op: "×" %>
<%= render 'shared/associativa_frecce', a: 6, b: 5, c: 2, op: "×", group: "right" %>
<%= render 'shared/associativa_parentesi', a: 6, b: 5, c: 2, op: "×", group: "left" %>
```

---

## PAGINE ESERCIZI (Quaderno p170+)

**IMPORTANTE:** Per le pagine del Quaderno Esercizi (p170 in poi) usare queste varianti:

### Box IMPARARE TUTTI (bordo GIALLO):
```erb
<div class="p-4 bg-white rounded-2xl border-3 border-yellow-400">
  <p class="font-bold text-gray-700 mb-4">
    <%= imparare_tutti_badge(1) %>
    Consegna esercizio...
  </p>
  <!-- contenuto -->
</div>
```

### NO wrapper sfondo esercizi
Gli esercizi sono direttamente dentro `<div class="space-y-6">`, senza il wrapper `bg-orange-100`.

### Tabelle stile CYAN:
```erb
<table class="w-full border-collapse border border-cyan-400">
  <thead>
    <tr>
      <th class="p-2 border border-cyan-400 bg-cyan-100 text-center text-gray-800">Header</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class="p-2 border border-cyan-400 text-center bg-white">Cella</td>
    </tr>
  </tbody>
</table>
```

### Colori CYAN fissi (non @pagina.base_color):
```erb
<span class="text-cyan-500">→</span>
<span class="text-cyan-500">•</span>
<div class="bg-cyan-50">sfondo evidenziato</div>
<span class="font-bold text-cyan-600">testo esempio</span>
```

### Box regole (bordo cyan, no rounded):
```erb
<div class="p-3 bg-white border-3 border-cyan-400">
  <p class="text-gray-600 italic">Per scrivere i numeri grandi suddividi le cifre in gruppi di tre, partendo da destra.</p>
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

## PAGINE MAPPA (Schema visivo gerarchico)

Per pagine che mostrano schemi/mappe concettuali con struttura gerarchica (es. p037 Addizione/Sottrazione):

### Struttura base MAPPA:
```erb
<div class="page-viewer bg-white dark:bg-gray-900 transition-colors duration-300"
     data-controller="exercise-checker text-toggle font-controls"
     data-text-toggle-target="content"
     data-font-controls-target="content">

  <%= render 'shared/page_header', pagina: @pagina %>

  <div class="space-y-8">
    <!-- Contenuto mappa -->
    <%= render 'shared/exercise_controls' %>
  </div>
</div>
```

### Tre livelli di colori:

**Livello 1 - Titoli principali:**
```erb
<div class="flex justify-center">
  <div class="bg-blue-500 text-white font-bold text-xl px-8 py-3 rounded-2xl shadow">
    TITOLO PRINCIPALE
  </div>
</div>
```

**Livello 2 - Sottotitoli:**
```erb
<div class="bg-cyan-500 text-white font-bold px-6 py-2 rounded-2xl text-center">
  STRUTTURA<br>DELL'OPERAZIONE
</div>
```

**Livello 3 - Proprietà/dettagli:**
```erb
<div class="bg-custom-blue-light dark:bg-cyan-900 border border-cyan-600 text-cyan-600 font-bold px-4 py-2 rounded-2xl">
  COMMUTATIVA
</div>
```

### Frecce (sempre cyan):
```erb
<span class="text-cyan-500 text-2xl">&#8595;</span>  <!-- freccia grande -->
<span class="text-cyan-500 text-xl">&#8595;</span>   <!-- freccia media -->
<span class="text-cyan-500 text-lg">&#8595;</span>   <!-- freccia piccola -->
```

### Box contenuto (testi/immagini):
```erb
<div class="bg-white dark:bg-gray-800 rounded-2xl p-3 shadow border border-cyan-500 dark:border-cyan-600 text-gray-700 dark:text-gray-200 text-left">
  Testo descrittivo...
</div>
```

### Immagini in dark mode:
```erb
<%= image_tag "nvi4_mat/p037/p037_01.jpg", class: "max-w-full h-auto dark:bg-white dark:rounded-lg dark:p-1" %>
```

### Layout con righe flex (NON grid/colonne):
```erb
<!-- Riga orizzontale -->
<div class="flex flex-row justify-center gap-8">
  <!-- Colonna sinistra -->
  <div class="flex flex-col items-center gap-3">
    <!-- livello 2 + freccia + contenuto -->
  </div>
  <!-- Colonna destra -->
  <div class="flex flex-col items-center gap-3">
    <!-- livello 2 + freccia + sotto-livelli -->
  </div>
</div>
```

### Immagini con dimensioni custom:
```erb
<%= image_tag "nvi4_mat/p037/p037_03.jpg", class: "w-[212px] h-auto" %>
```

### Caratteristiche MAPPE:
- ✅ `page-viewer bg-white dark:bg-gray-900` (sfondo bianco/scuro)
- ✅ Righe flex orizzontali (`flex flex-row`)
- ✅ Box `rounded-2xl` con `shadow` e `border-cyan-500 dark:border-cyan-600`
- ✅ Testi `text-left text-gray-700 dark:text-gray-200` (allineati a sinistra)
- ✅ **NESSUNA dimensione testo fissa** (no text-sm, text-lg, ecc.)
- ✅ Frecce `text-cyan-500`
- ✅ Immagini con `dark:bg-white dark:rounded-lg dark:p-1` per sfondo bianco in dark mode

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
- [ ] **Se pagina ESERCIZI (p170+):** Box IMPARARE TUTTI con `border-yellow-400`
- [ ] **Se pagina ESERCIZI:** Tabelle con stile cyan (`border-cyan-400`, `bg-cyan-100`)
- [ ] **Se pagina ESERCIZI:** Colori cyan fissi invece di `@pagina.base_color`
- [ ] **Se pagina ESERCIZI:** NO wrapper `bg-orange-100` per esercizi
