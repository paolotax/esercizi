# Pattern Box - Riepilogo Correzioni P221-P264

Questo documento riassume tutti i pattern da applicare alle pagine precedenti (p001-p220).

---

## 1. TABELLE TEORIA (Misure: lunghezza, massa, tempo, superficie, volume)

### Prima (da correggere):
```html
<div class="overflow-x-auto">
  <table class="w-full border-collapse border border-cyan-400">
    <tr>
      <th class="bg-custom-blue-light text-gray-800">MULTIPLI</th>
      <th class="bg-cyan-200 text-gray-800">UNITÀ FONDAMENTALE</th>
      <th class="bg-custom-blue-light text-gray-800">SOTTOMULTIPLI</th>
    </tr>
```

### Dopo (corretto):
```html
<div class="p-4 md:p-6 bg-custom-blue-light rounded-3xl">
  <div class="overflow-x-auto">
    <table class="w-full border-collapse border border-cyan-400">
      <tr>
        <th class="bg-white text-cyan-600 font-bold">MULTIPLI</th>
        <th class="bg-gray-200 text-cyan-600 font-bold">UNITÀ FONDAMENTALE</th>
        <th class="bg-white text-cyan-600 font-bold">SOTTOMULTIPLI</th>
      </tr>
```

### Regole:
- Box esterno: `p-4 md:p-6 bg-custom-blue-light rounded-3xl`
- Header MULTIPLI/SOTTOMULTIPLI: `bg-white text-cyan-600 font-bold`
- Header UNITÀ FONDAMENTALE: `bg-gray-200 text-cyan-600 font-bold`
- Celle unità fondamentale: `bg-gray-200`
- Testo unità fondamentale: `font-bold text-cyan-600`
- Celle normali: `bg-white`

---

## 2. BOX TEORIA (Formule geometria, commercio, ecc.)

### Prima:
```html
<div class="p-4 bg-custom-blue-light rounded-lg">
```

### Dopo:
```html
<div class="p-4 bg-custom-blue-light rounded-2xl w-fit mx-auto">
```

### Regole:
- `rounded-lg` → `rounded-2xl`
- Aggiungere `w-fit mx-auto` per centrare
- Immagini interne: `max-w-sm` (non `max-w-[150px]`)

---

## 3. TABELLE ESERCIZI (non full-width)

### Prima:
```html
<div class="overflow-x-auto">
  <table class="w-full border-collapse border border-cyan-400">
```

### Dopo:
```html
<div class="overflow-x-auto flex justify-center">
  <table class="border-collapse border border-cyan-400">
```

### Regole:
- Rimuovere `w-full` dalla tabella
- Aggiungere `flex justify-center` al container
- La tabella prende solo lo spazio necessario

---

## 4. VERO/FALSO

### Prima:
```html
<div class="flex items-center justify-between gap-4 p-2 border border-gray-200 rounded">
```

### Dopo:
```html
<div class="flex items-center justify-between gap-4 p-2">
```

### Regole:
- Rimuovere `border border-gray-200 rounded`
- Mantenere solo `p-2` per padding

---

## 5. BOX SINGOLI ESERCIZI/ANGOLI

### Prima:
```html
<div class="text-center p-3 border border-gray-200 rounded-lg">
```

### Dopo:
```html
<div class="text-center p-3">
```

### Regole:
- Rimuovere `border border-gray-200 rounded-lg`

---

## 6. LAYOUT PROBLEMI (2 colonne con divider)

### Prima:
```html
<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
  <div class="p-4 bg-custom-blue-light rounded-2xl">
```

### Dopo:
```html
<div class="grid grid-cols-1 md:grid-cols-2 md:divide-x-2 divide-cyan-300">
  <div class="space-y-4 p-4">
```

### Regole:
- Aggiungere `md:divide-x-2 divide-cyan-300` al grid
- Rimuovere `bg-custom-blue-light rounded-2xl` dai singoli problemi
- Usare `space-y-4 p-4` per le colonne

---

## 7. BOX PROBLEMI SINGOLI

### Prima:
```html
<div class="p-4 bg-custom-blue-light rounded-2xl">
```

### Dopo:
```html
<div class="p-4 bg-white rounded-2xl border border-cyan-300">
```

### Regole:
- `bg-custom-blue-light` → `bg-white`
- Aggiungere `border border-cyan-300`

---

## 8. RISPOSTE/INPUT

### Regole:
- Allineare a destra: `justify-end`
- Unità di misura fuori dall'input
- Formato: `<input> <span>unità</span>` o `<span>€</span> <input>`

### Esempio:
```html
<div class="flex items-center gap-2 justify-end mt-2">
  <input type="text" data-correct-answer="215" class="w-20 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
  <span class="text-gray-700">€</span>
</div>
```

---

## 9. NUMERI GRANDI

### Regole:
- Usare `whitespace-nowrap` per evitare spezzature
- Formato: `<span class="whitespace-nowrap">1 000 000</span>`

---

## 10. IMPARARE TUTTI

### Pattern fisso (non modificare):
```html
<div class="p-4 bg-white rounded-2xl border-3 border-yellow-400">
  <p class="font-bold text-gray-700 mb-4">
    <%= imparare_tutti_badge(N) %>
    Testo esercizio.
  </p>
  <!-- contenuto -->
</div>
```

---

## 11. GRID RESPONSIVE

### Pattern per esercizi multipli:
```html
<!-- 2 colonne su sm, 3 su md -->
<div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">

<!-- 4 colonne con divider solo su xl -->
<div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 xl:divide-x-2 divide-cyan-300">
```

---

## 12. TESTO EVIDENZIATO

### Regole:
- Parole chiave: `text-cyan-600 font-bold`
- Bullet point: `text-cyan-500`
- Esempio risposta: `font-bold text-cyan-600`

---

## Riepilogo Correzioni per Sezione

| Sezione | Pattern |
|---------|---------|
| Tabelle teoria misure | Box rounded-3xl, header bg-white/bg-gray-200, text-cyan-600 |
| Box teoria formule | rounded-2xl, w-fit mx-auto |
| Tabelle esercizi | No w-full, flex justify-center |
| Vero/Falso | No border, solo p-2 |
| Box singoli | No border-gray-200 |
| Layout 2 colonne | divide-x-2 divide-cyan-300 |
| Box problemi | bg-white + border-cyan-300 |
| Input risposte | justify-end, unità fuori |
| Numeri grandi | whitespace-nowrap |

---

## Pagine da Verificare (P001-P220)

Cercare e correggere:
1. `bg-cyan-200` nelle tabelle → `bg-gray-200`
2. `text-cyan-700` → `text-cyan-600`
3. `rounded-lg` nei box teoria → `rounded-2xl` o `rounded-3xl`
4. `border border-gray-200 rounded` nei V/F → rimuovere
5. `w-full` nelle tabelle centrabili → rimuovere + flex justify-center
6. `bg-custom-blue-light rounded-2xl` nei problemi → bg-white + border

### Comandi grep utili:
```bash
# Trova bg-cyan-200
grep -rn "bg-cyan-200" app/views/exercises/nvi5_mat_p*.html.erb

# Trova text-cyan-700
grep -rn "text-cyan-700" app/views/exercises/nvi5_mat_p*.html.erb

# Trova border-gray-200 nei V/F
grep -rn "border-gray-200 rounded" app/views/exercises/nvi5_mat_p*.html.erb

# Trova rounded-lg nei box teoria
grep -rn "bg-custom-blue-light rounded-lg" app/views/exercises/nvi5_mat_p*.html.erb
```

---

## 13. VERIFICA ESERCIZI SENZA INPUT

### Problema:
Alcune pagine hanno problemi "da risolvere sul quaderno" senza campi input per le risposte.

### Come trovare:
```bash
# Trova pagine con "sul quaderno"
grep -l "sul quaderno\|Risolvi sul" app/views/exercises/nvi5_mat_p*.html.erb

# Conta input per file
for f in app/views/exercises/nvi5_mat_p{001..220}.html.erb; do
  count=$(grep -c "data-correct-answer" "$f" 2>/dev/null || echo 0)
  echo "$(basename $f): $count inputs"
done
```

### Pattern per aggiungere input:

**Risposta singola (euro):**
```html
<div class="flex items-center gap-2 justify-end mt-2">
  <span class="text-gray-700">€</span>
  <input type="text" data-correct-answer="346,50" class="w-24 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
</div>
```

**Risposta singola (unità dopo):**
```html
<div class="flex items-center gap-2 justify-end">
  <input type="text" data-correct-answer="1700" class="w-24 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
  <span class="text-gray-700">tessere</span>
</div>
```

**Risposte multiple:**
```html
<div class="flex items-center gap-2 justify-end">
  <span class="text-gray-700">Totale: €</span>
  <input type="text" data-correct-answer="210" class="w-20 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
  <span class="text-gray-700 ml-2">Ciascuno: €</span>
  <input type="text" data-correct-answer="10,50" class="w-20 border-b-2 border-dotted border-gray-400 text-center font-bold bg-transparent">
</div>
```

### Regole:
- Usare `justify-end` per allineare a destra
- Usare `mt-2` solo dentro box IMPARARE TUTTI (che hanno `mb-4` sul paragrafo)
- Input width: `w-20` per valori corti, `w-24` per valori più lunghi
- Decimali italiani: usare virgola (es. `346,50` non `346.50`)
- Per problemi con più domande: un input per ogni risposta richiesta
