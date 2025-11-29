# Prompt per Generare Pagine Geometria BUS3

Usa questo prompt per creare nuove pagine di esercizi di geometria seguendo lo stile delle pagine 090-100.

---

## IMPORTANTE: Prima di Iniziare

**Controlla SEMPRE questi due riferimenti:**

1. **HTML originale** - Leggi il file HTML con il testo estratto dalla pagina:
   ```
   app/assets/images/bus3_mat/pXXX/17*.html
   ```
   (es: `1743504902100.html` per p100)
   Questo file contiene il testo originale della pagina del libro, utile per copiare i contenuti corretti.

2. **Immagine originale** - Visualizza il `page.png` per vedere il layout originale del libro:
   ```
   app/assets/images/bus3_mat/pXXX/page.png
   ```

Questi due file sono i riferimenti principali per:
- Copiare il testo corretto dal `page.html`
- Capire la struttura degli esercizi dal `page.png`
- Verificare quali testi sono già nelle immagini (non duplicarli!)
- Controllare i colori dei box e degli sfondi
- Identificare il tipo di esercizio (completamento, selezione, disegno, ecc.)

---

## Struttura Base della Pagina

```erb
<div class="max-w-7xl mx-auto p-3 md:p-6 bg-white font-mono text-base lg:text-lg xl:text-xl"
     data-controller="exercise-checker page-viewer text-toggle font-controls"
     data-page-viewer-image-url-value="<%= asset_path('bus3_mat/pXXX/page.png') %>"
     data-text-toggle-target="content"
     data-font-controls-target="content">

  <!-- Header -->
  <%= render 'shared/page_header', pagina: @pagina %>

  <!-- Contenuto esercizi qui -->

  <!-- Footer con controlli -->
  <%= render 'shared/exercise_controls' %>
</div>
```

---

## Convenzioni di Stile

### 1. Box Introduttivo/Teoria con Sfondo Azzurro
```erb
<div class="bg-[#C7EAFB] p-4 md:p-6 -mx-3 md:mx-0 mb-12">
  <!-- contenuto -->
</div>
```

### 2. Box Definizione/Regola (bianco con bordo rosa)
```erb
<div class="bg-white border-3 border-pink-300 rounded-lg py-2 px-4">
  <p><strong>Testo della regola con <span class="text-cyan-600 font-bold">parole chiave</span>.</strong></p>
</div>
```

### 3. Numero Esercizio (pallino rosso)
```erb
<div class="flex items-start gap-3 mb-4">
  <div class="bg-red-500 text-white rounded-full w-8 h-8 flex items-center justify-center md:items-start font-bold flex-shrink-0">
    1
  </div>
  <p class="text-gray-700">
    <strong>Testo della consegna.</strong>
  </p>
</div>
```

### 4. Pallino Rosso Inline (per liste)
```erb
<p><span class="text-red-500">•</span> Testo del punto.</p>
```

### 5. Parole Chiave/Termini Tecnici
```erb
<span class="text-cyan-600 font-bold">termine</span>
```

### 6. Badge LABORATORIO
```erb
<span class="bg-gradient-to-r from-red-500 via-yellow-500 to-green-500 text-white px-3 py-1 rounded font-bold text-sm">L A B O R A T O R I O</span>
```

### 7. Badge GIOCO
```erb
<span class="bg-gradient-to-r from-green-500 via-cyan-500 to-blue-500 text-white px-3 py-1 rounded font-bold text-sm whitespace-nowrap">G I O C O</span>
```

### 8. Badge mate VIVA
```erb
<span class="bg-blue-600 text-white px-3 py-1 rounded font-bold text-sm">mate VIVA</span>
```

### 9. Spaziatura tra Esercizi
```erb
<div class="mb-12">
  <!-- esercizio -->
</div>
```

### 10. Link Quaderno
```erb
<div class="p-4 mb-8 text-right">
  <span class="text-gray-600">Quaderno →</span> <%= link_to "p. 165", pagina_path("bus3_mat_p165"), class: "text-cyan-600 font-bold hover:underline" %>
</div>
```

---

## Tipi di Esercizi Interattivi

### A. Input Completamento (fill-blanks)
```erb
<div class="mb-12" data-controller="fill-blanks auto-advance">
  <input type="text" data-fill-blanks-target="input" data-correct-answer="risposta"
         class="w-16 px-2 py-1 border-b-2 border-dotted border-gray-400 text-center" inputmode="numeric">
</div>
```

### B. Selezione Card (card-selector)
```erb
<div data-controller="card-selector">
  <div class="space-y-2">
    <div class="bg-white border border-gray-300 rounded px-3 py-1 cursor-pointer"
         data-card-selector-target="card" data-correct="false"
         data-action="click->card-selector#select">Opzione errata</div>
    <div class="bg-white border border-gray-300 rounded px-3 py-1 cursor-pointer"
         data-card-selector-target="card" data-correct="true"
         data-action="click->card-selector#select">Opzione corretta</div>
  </div>
</div>
```

### C. Figure SVG Colorabili (svg-colorable)
```erb
<div class="mb-12" data-controller="svg-colorable">
  <div class="grid grid-cols-4 gap-4">
    <!-- Poligono (corretto) -->
    <div class="flex justify-center">
      <svg viewBox="0 0 100 100" class="w-20 h-20 cursor-pointer">
        <path d="M50 10 L90 38 L75 90 L25 90 L10 38 Z"
              fill="white" stroke="currentColor" stroke-width="1.5"
              data-svg-colorable-target="cell" data-correct="true"
              data-action="click->svg-colorable#toggleCell" />
      </svg>
    </div>
    <!-- Non poligono (errato) -->
    <div class="flex justify-center">
      <svg viewBox="0 0 100 80" class="w-24 h-20 cursor-pointer">
        <ellipse cx="50" cy="40" rx="40" ry="30"
                 fill="white" stroke="currentColor" stroke-width="1.5"
                 data-svg-colorable-target="cell" data-correct="false"
                 data-action="click->svg-colorable#toggleCell" />
      </svg>
    </div>
  </div>
</div>
```

### D. Hotspot su Immagine (hotspot-labels)
```erb
<div class="relative" data-controller="hotspot-labels">
  <%= image_tag "bus3_mat/pXXX/immagine.jpg", alt: "Descrizione", class: "w-full" %>
  <div class="absolute" style="top: 20%; left: 30%;">
    <input type="text" data-hotspot-labels-target="input" data-correct-answer="risposta"
           class="w-20 px-1 py-0.5 border-b-2 border-dotted border-gray-400 text-center bg-white/80">
  </div>
</div>
```

### E. Evidenziatore Parole/Cifre (word-highlighter)

**IMPORTANTE**: Quando l'esercizio originale dice "Cerchia" o "Sottolinea", nella versione digitale la consegna deve sempre dire **"Colora"**, perché l'interazione è un click che colora/evidenzia.

```erb
<div class="mb-12" data-controller="word-highlighter" data-word-highlighter-multi-color-value="true">
  <div class="flex items-center gap-3 mb-6">
    <div class="bg-red-500 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold flex-shrink-0">
      1
    </div>
    <p class="text-gray-700"><strong>Colora di
      <span class="w-5 h-5 bg-blue-300 rounded inline-block align-middle cursor-pointer ring-2 ring-transparent hover:ring-blue-500"
            data-word-highlighter-target="colorBox"
            data-color="blue"
            data-action="click->word-highlighter#selectColor"></span>
      <span class="text-blue-500">blu la parte intera</span> e di
      <span class="w-5 h-5 bg-yellow-300 rounded inline-block align-middle cursor-pointer ring-2 ring-transparent hover:ring-yellow-500"
            data-word-highlighter-target="colorBox"
            data-color="yellow"
            data-action="click->word-highlighter#selectColor"></span>
      <span class="text-yellow-500">giallo la parte decimale</span> di questi numeri.</strong></p>
  </div>

  <div class="grid grid-cols-3 md:grid-cols-4 gap-4 text-center text-xl">
    <div class="p-3 bg-gray-50 rounded cursor-pointer">
      <span data-word-highlighter-target="word" data-correct="blue" data-action="click->word-highlighter#toggleHighlight">2</span><span class="text-red-500">,</span><span data-word-highlighter-target="word" data-correct="yellow" data-action="click->word-highlighter#toggleHighlight">4</span><span data-word-highlighter-target="word" data-correct="yellow" data-action="click->word-highlighter#toggleHighlight">1</span>
    </div>
  </div>
</div>
```

**Colori disponibili**: blue, yellow, red, green, pink, purple, orange, cyan

**Attributi chiave**:
- `data-word-highlighter-multi-color-value="true"` - abilita più colori
- `data-word-highlighter-target="colorBox"` - box selettore colore
- `data-word-highlighter-target="word"` - elemento cliccabile
- `data-correct="blue"` - colore corretto per la verifica
- `data-correct=""` - elemento che NON deve essere colorato

---

## Immagini

### Dimensioni Consigliate
- Immagine grande centrata: `class="max-w-3xl w-full"`
- Immagine media: `class="max-w-md"` o `class="max-w-xs"`
- Icona/piccola: `class="max-h-24"` o `class="max-h-20"`

### Formato
```erb
<div class="flex justify-center mb-6">
  <%= image_tag "bus3_mat/pXXX/immagine.jpg", alt: "Descrizione", class: "max-w-3xl w-full" %>
</div>
```

---

## Grid Layout

### 2 colonne
```erb
<div class="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">
```

### 3 colonne
```erb
<div class="grid grid-cols-1 sm:grid-cols-3 gap-4 md:gap-6">
```

### 4 colonne
```erb
<div class="grid grid-cols-2 md:grid-cols-4 gap-4">
```

---

## Checklist Prima di Completare

- [ ] NON usare classi font-size fisse (`text-sm`, `text-xs`) - lascia che font-controls gestisca
- [ ] Usare `mb-12` per separare gli esercizi
- [ ] Box teoria: `bg-white border-3 border-pink-300`
- [ ] Box introduzione: `bg-[#C7EAFB]`
- [ ] Parole chiave: `text-cyan-600 font-bold`
- [ ] Chiamata exercise_controls SENZA parametro color
- [ ] Immagini con alt descrittivo
- [ ] Controller Stimulus appropriati per interattività

---

## Ogni 5 Pagine: Seed e Indice

**Ogni 5 pagine completate**, esegui questi passaggi:

### 1. Aggiorna il file seeds
Aggiungi le nuove pagine in `db/seeds.rb`:
```ruby
# Pagine XXX-YYY - Geometria
{ codice: "bus3_mat_pXXX", titolo: "Titolo Argomento", numero: XXX, libro: bus3_mat, materia: "matematica", ordine: XXX },
{ codice: "bus3_mat_pXXX", titolo: "Titolo Argomento", numero: XXX, libro: bus3_mat, materia: "matematica", ordine: XXX },
...
```

### 2. Aggiorna l'indice in index.html.erb
Aggiungi i link alle nuove pagine in `app/views/exercises/index.html.erb`:
```erb
<%= link_to "p. XXX", pagina_path("bus3_mat_pXXX"), class: "..." %>
```

### 3. Esegui il seed (se necessario)
```bash
bin/rails db:seed
```

### 4. Committa il batch
```bash
git add .
git commit -m "feat: aggiungi pagine XXX-YYY geometria"
```

---

## Esempio Pagina Completa

Vedi `/app/views/exercises/bus3_mat_p096.html.erb` o `/app/views/exercises/bus3_mat_p100.html.erb` come riferimento.
