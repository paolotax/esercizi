# Revisione Pagine nvi5_mat

Revisionare la pagina $ARGUMENTS seguendo i pattern stabiliti nelle pagine 56-59.

---

## PROCEDURA

1. **Leggi page.png** - `assets/images/nvi5_mat/p0XX/page.png`
2. **Analizza la struttura** - Identifica sezioni, colonne, box colorati
3. **Identifica controller** - Quale tipo di interazione serve?
4. **Verifica immagini** - Controlla quali immagini esistono nella cartella
5. **Applica i pattern** - Usa i template sotto
6. **Testa** - Verifica che la pagina funzioni

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

## PARTIAL FRAZIONE

```erb
<%= render 'shared/frazione', num: 2, den: 3, bold: true %>
<%= render 'shared/frazione', num: nil, den: 3, num_answer: "2" %>
<%= render 'shared/frazione', num: 3, den: nil, den_answer: "5" %>
<%= render 'shared/frazione', num: nil, den: nil, num_answer: "2", den_answer: "3",
    input_data: "equivalent-fractions-target=input" %>
```

---

## BADGE ESERCIZI

```erb
<%= numero_esercizio_badge(1, colore: "cyan-500") %>
<%= imparare_tutti_badge(1) %>
```

---

## LAYOUT

**Due colonne con divisore:**
```erb
<div class="grid grid-cols-1 md:grid-cols-2 divide-y-2 md:divide-y-0 md:divide-x-2 divide-<%= @pagina.base_color %>-600">
```

**Testo + immagine:**
```erb
<div class="flex flex-col md:flex-row gap-6">
  <div class="flex-1"><!-- Testo --></div>
  <div class="flex-shrink-0"><%= image_tag "...", class: "max-w-xs" %></div>
</div>
```

---

## BOX COLORATI

- **Regola (rosa):** `bg-pink-100 rounded-2xl`
- **Problema (celeste):** `bg-cyan-50`
- **Risposta:** `bg-cyan-100 rounded-lg`
- **Esercizi:** `bg-orange-100 rounded-lg`

---

## TITOLI

```erb
<h2 class="font-bold text-<%= @pagina.base_color %>-600 mb-4 italic">Titolo</h2>
<p><strong><span class="text-pink-600">•</span> Istruzione</strong></p>
```

---

## STIMULUS CONTROLLERS

**svg-colorable:** Per colorare figure
```erb
<div data-controller="svg-colorable" data-svg-colorable-color-value="#ffc0cb">
  <path data-svg-colorable-target="cell" data-action="click->svg-colorable#toggleCell"/>
</div>
```

**word-highlighter:** Per cerchiare elementi
```erb
<div data-controller="word-highlighter" data-word-highlighter-multi-color-value="false">
  <span data-word-highlighter-target="word" data-correct="yellow"
        data-action="click->word-highlighter#toggleHighlight">
</div>
```

**equivalent-fractions:** Per frazioni equivalenti
```erb
<div data-controller="equivalent-fractions">
  <div data-equivalent-fractions-target="fractionGroup" data-original-num="4" data-original-den="9">
```

---

## CHECKLIST

- [ ] Container `bg-white` + data-controllers
- [ ] Header `page_header`
- [ ] Frazioni con partial `_frazione`
- [ ] Badge con helper
- [ ] Layout responsive (md:)
- [ ] Box colorati
- [ ] Input con `data-correct-answer`
- [ ] Footer `exercise_controls`
