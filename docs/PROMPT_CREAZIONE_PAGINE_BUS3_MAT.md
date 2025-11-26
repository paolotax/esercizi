# PROMPT PER CREAZIONE PAGINE BUS3_MAT

## OBIETTIVO
Creare pagine interattive HTML/ERB per il volume bus3_mat seguendo lo stile delle pagine esistenti (p010-p011-p012).

## OPERAZIONI DA ESEGUIRE

### 1. ANALISI PRELIMINARE
- [ ] Verificare esistenza file HTML esistente in `app/views/exercises/bus3_mat_pXXX.html.erb`
- [ ] Verificare esistenza immagini in `app/assets/images/bus3_mat/pXXX/`
- [ ] Leggere file `1743504902XXX.html` per capire contenuto esercizi
- [ ] Leggere `page.png` per vedere layout originale
- [ ] Elencare tutte le immagini disponibili (jpg, png) nella cartella

### 2. STILE E LAYOUT RICHIESTO

**Container principale:**
```erb
<div class="max-w-7xl mx-auto p-3 md:p-6"
     data-controller="exercise-checker">

  <!-- Header -->
  <%= render 'shared/page_header', pagina: @pagina %>

  <!-- contenuto -->

  <!-- Footer con controlli -->
  <%= render 'shared/exercise_controls' %>

</div>
```

**Numero esercizio:**
```erb
<div class="bg-red-500 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold flex-shrink-0">
  1
</div>
```

**Container esercizio:**
```erb
<div class="bg-transparent p-4 md:p-8 mb-8" data-controller="fill-blanks auto-advance">
  <!-- contenuto -->
</div>
```

**Box informativi/teorici:**
```erb
<div class="bg-[#C7EAFB] p-4 md:p-6 mb-8">
  <!-- per NUMERI usa #C7EAFB (azzurro) -->
</div>

<div class="bg-[#FFE4C4] p-4 md:p-6 mb-8">
  <!-- per ADDIZIONI usa #FFE4C4 (pesca) -->
</div>
```

**Bordi:**
- NUMERI: `border-3 border-cyan-400 rounded-lg`
- ADDIZIONI: `border-3 border-orange-400 rounded-lg`

**Input fields:**
```erb
<input type="text"
       data-fill-blanks-target="input"
       data-correct-answer="RISPOSTA"
       class="w-20 px-2 py-1 border-b-2 border-dotted border-gray-400 text-center font-bold"
       maxlength="3"
       inputmode="numeric">
```

**Checkbox custom (per esercizi con X):**
```erb
<style>
  .custom-checkbox {
    appearance: none;
    width: 1.75rem;
    height: 1.75rem;
    border: 2px solid #67e8f9;
    border-radius: 0.25rem;
    position: relative;
    cursor: pointer;
  }
  .custom-checkbox:checked {
    background-color: white;
  }
  .custom-checkbox:checked::after {
    content: '';
    position: absolute;
    left: 50%;
    top: 50%;
    width: 0.875rem;
    height: 0.125rem;
    background-color: #ef4444;
    transform: translate(-50%, -50%) rotate(45deg);
  }
  .custom-checkbox:checked::before {
    content: '';
    position: absolute;
    left: 50%;
    top: 50%;
    width: 0.875rem;
    height: 0.125rem;
    background-color: #ef4444;
    transform: translate(-50%, -50%) rotate(-45deg);
  }
</style>

<input type="checkbox"
       data-correct-answer="true"
       class="custom-checkbox">
```



### 3. IMMAGINI

**Usare immagini esistenti:**
```erb
<%= image_tag "bus3_mat/pXXX/nome_immagine.jpg",
    alt: "Descrizione",
    class: "max-w-4xl w-full" %>
```

**IMPORTANTE:**
- Usare SOLO immagini che esistono nella cartella
- NON inventare nomi di immagini
- Verificare con `ls app/assets/images/bus3_mat/pXXX/`

### 4. CONTROLLER STIMULUS

**Controller da includere sempre:**
- `exercise-checker`: per verifica risposte
- `page-viewer`: per visualizzare page.png
- `fill-blanks`: per input con risposte
- `auto-advance`: per avanzamento automatico


### 5. PATTERN COMUNI

**Tabella con bordi:**
```erb
<div class="border-3 border-cyan-400 rounded-2xl overflow-hidden">
  <table class="w-full">
    <tbody>
      <tr>
        <td class="border-2 border-cyan-400 px-4 py-3 text-center font-bold bg-white">
          Contenuto
        </td>
      </tr>
    </tbody>
  </table>
</div>
```

**Grid responsive:**
```erb
<div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
  <!-- colonne -->
</div>
```

**Problema con operazione:**
```erb
<div class="p-4">
  <p class="text-base text-gray-700 mb-4">
    Testo del problema
  </p>
  <div class="flex items-center gap-3">
    <input type="text" data-fill-blanks-target="input" data-correct-answer="XX"
           class="w-16 px-2 py-1 border-b-2 border-dotted border-gray-400 text-center font-bold"
           maxlength="2" inputmode="numeric">
    <span class="font-bold">+</span>
    <input type="text" data-fill-blanks-target="input" data-correct-answer="YY"
           class="w-16 px-2 py-1 border-b-2 border-dotted border-gray-400 text-center font-bold"
           maxlength="2" inputmode="numeric">
    <span class="font-bold">=</span>
    <input type="text" data-fill-blanks-target="input" data-correct-answer="ZZ"
           class="w-16 px-2 py-1 border-b-2 border-dotted border-gray-400 text-center font-bold"
           maxlength="2" inputmode="numeric">
    <span class="text-gray-700">unità</span>
  </div>
</div>
```

### 7. CHECKLIST FINALE

- [ ] Tutti gli esercizi sono interattivi con input/checkbox
- [ ] Tutte le risposte corrette sono specificate in `data-correct-answer`
- [ ] Le immagini sono tutte presenti e caricate correttamente
- [ ] Il layout è semplice e pulito (NO gradienti complessi, NO shadow-lg)
- [ ] Header e footer sono inclusi con i partial corretti
- [ ] I controller Stimulus sono tutti specificati
- [ ] Il codice è responsive (usa md: breakpoint)

### 8. COSA NON FARE

❌ NON usare:
- Non scrivere Titolo e Sottotitolo della pagina. Ci pensa il partial
- `bg-gradient-to-b` (solo bg-white)
- `shadow-lg` `shadow-xl` (troppo pesante)
- `rounded-xl` (usa rounded-lg)
- Colori personalizzati non standard
- Immagini che non esistono nella cartella
- Layout complessi con troppe div annidate

✅ USARE:
- Layout semplice e pulito
- Bordi colorati per evidenziare
- Bg colorati leggeri per box informativi
- Input con border-dotted
- Classi Tailwind standard

### 9. DOPO LA CREAZIONE

1. **Aggiornare seed.rb:**
```ruby
{ numero: XX, titolo: "TITOLO PAGINA", sottotitolo: "MATERIA",
  slug: "bus3_mat_pXXX", view_template: "bus3_mat_pXXX",
  base_color: "cyan" }, # o "orange"
```

2. **Aggiornare indice in `_bus3_mat_index_page_2.html.erb`:**
```erb
<div class="flex justify-between items-center hover:bg-gray-50 px-2 py-1 rounded">
  <span class="text-orange-500">●</span>
  <%= link_to "TITOLO PAGINA", "bus3_mat_pXXX", class: "flex-1 ml-2 font-medium" %>
  <span class="text-gray-700">XX</span>
</div>
```

3. **Rigenerare database:**
```bash
rails db:seed
```

4. **Verificare la pagina:**
```
http://localhost:3000/exercises/bus3_mat_pXXX
```

## ESEMPIO COMPLETO

Vedi pagine di riferimento:
- `app/views/exercises/bus3_mat_p010.html.erb` (NUMERI - tabelle)
- `app/views/exercises/bus3_mat_p013.html.erb` (NUMERI - esercizi misti)


## NOTE FINALI

- Segui SEMPRE lo stile delle pagine p010-p013
- Leggi SEMPRE l'HTML originale ed il page.png prima di creare
- Usa SOLO le immagini che esistono
- Testa la pagina dopo averla creata
- Mantieni il codice SEMPLICE e PULITO
