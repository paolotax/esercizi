# Prompt per Generare Pagine Geometria BUS3

Usa questo prompt per creare nuove pagine di esercizi di geometria seguendo lo stile delle pagine 090-100.

---

## Struttura Base della Pagina

```erb
<% content_for :titolo, "#{@pagina.titolo} - #{@pagina.numero}" %>

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
  <div class="bg-red-500 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold flex-shrink-0">
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

## Esempio Pagina Completa

Vedi `/app/views/exercises/bus3_mat_p096.html.erb` o `/app/views/exercises/bus3_mat_p100.html.erb` come riferimento.
