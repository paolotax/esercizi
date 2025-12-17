# CORREZIONI BOX P171-P180

## Procedura

Quando eseguo le correzioni:
- Se modifico **titolo** o **sottotitolo** → aggiorno anche il seed
- Se modifico **base_color** → aggiorno anche il seed
- Alla fine delle correzioni → riscrivo questo file con le modifiche fatte

---

## p171 - RELAZIONI, DATI E PREVISIONI (base_color: pink)
**Sottotitolo:** MODELLO INVALSI

### Box utilizzati:
- Layout 2 colonne (`grid grid-cols-1 md:grid-cols-2`)
- Istogramma con tabella colorata (celle colorate dinamiche)
- Tabella temperature (`border-collapse border border-gray-300`, header `bg-gray-50`)
- Tabella dado (simboli Unicode &#9856;-&#9861;)
- Checkbox multipla con label hover (`hover:bg-gray-50 p-2 rounded border border-gray-200`)
- Esercizi con numero_esercizio_badge

### Correzioni da fare:
NESSUNA

---

## p172 - LE CARTE ELETTRONICHE (base_color: pink)
**Sottotitolo:** Educazione finanziaria

### Box utilizzati:
- Testo introduttivo semplice
- Immagine centrata (`flex justify-center`)
- Layout 2 colonne (`grid grid-cols-1 md:grid-cols-2`)
- Box vantaggi (`p-4 bg-pink-light rounded-lg`)
- Lista con marker colorato (`list-disc pl-6 marker:text-<%= @pagina.base_color %>-500`)
- Box "Per crescere" Life skills (`p-4 bg-custom-pink/10 rounded-2xl border-3 border-custom-pink`)

### Correzioni da fare:
NESSUNA

---

## p173 - LA BANCA E IL CONTO CORRENTE (base_color: pink)
**Sottotitolo:** Educazione finanziaria

### Box utilizzati:
- Box introduttivo (`p-4 bg-pink-light rounded-lg`)
- Layout 2 colonne (`grid grid-cols-1 md:grid-cols-2`)
- Box definizione conto corrente (`p-4 bg-custom-blue rounded-lg`)
- Placeholder emoji banca (div con emoji)
- Immagine centrata
- Box interesse (`p-4 bg-pink-light rounded-lg`)
- Box definizione investire (`p-4 bg-white rounded-2xl border-3 border-<%= @pagina.base_color %>-400`)
- Box esercizio (`p-4 bg-custom-pink/10 rounded-2xl border-3 border-custom-pink`) con input

### Correzioni da fare:
NESSUNA

---

## p174 - FINANZIAMENTO E INTERESSI (base_color: pink)
**Sottotitolo:** Educazione finanziaria

### Box utilizzati:
- Box introduttivo (`p-4 bg-pink-light rounded-lg`)
- Layout 2 colonne (`grid grid-cols-1 md:grid-cols-2`)
- Box interesse (`p-4 bg-custom-blue rounded-lg`)
- Immagine vignetta (`max-w-full rounded-lg shadow-md`)
- Box tipi interesse (`p-4 bg-pink-light rounded-lg`) con lista
- Box esercizio (`p-4 bg-custom-pink/10 rounded-2xl border-3 border-custom-pink`) con input

### Correzioni da fare:
NESSUNA

---

## p175 - IL MIO QUADERNO DEGLI ESERCIZI (base_color: cyan)
**Sottotitolo:** INDICE

### Box utilizzati:
- Indice 2 colonne (`grid grid-cols-1 md:grid-cols-2`)
- Link su tutta la riga (`link_to ... do`)
- Pallino colorato (`text-cyan-500`)
- Badge RIPASSO (`bg-cyan-500 text-white px-2 py-0.5 rounded text-xs font-bold`)
- Box IMPARARE TUTTI (`bg-yellow-400 text-blue-700 font-bold px-2 py-0.5 rounded-full`)

### Correzioni fatte:
- Link copertura intera riga con `link_to ... do` block
- Box IMPARARE TUTTI in basso a destra con stile giallo/blu
- Exercise controls in fondo

---

## p176 - MILIONI E MILIARDI (base_color: cyan) ✅ CORRETTO
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Tabella classi posizionali (`border border-cyan-400 bg-cyan-100 text-gray-800`)
- Box IMPARARE TUTTI (`p-4 bg-white rounded-2xl border-3 border-yellow-400`)
- imparare_tutti_badge(1)
- Tabella inserimento numeri con input e `data-correct-answer`
- Layout 2 colonne con word-highlighter per esercizio 2
- Box regola a destra (`p-3 bg-white border-3 border-cyan-400`)

### Correzioni fatte:
- base_color da blue a cyan (seed aggiornato)
- Box esercizi: rimosso bg/rounded/border wrapper
- Box IMPARARE TUTTI: border-3 border-yellow-400 (bordo giallo)
- Tabelle: header bg-cyan-100, celle bg-white, griglia border-cyan-400
- Esercizio 2: layout 2 colonne con word-highlighter
- Input con data-correct-answer
- Box regola con border-3 border-cyan-400

---

## p177 - SCRITTURE DIVERSE DEI NUMERI (base_color: cyan) ✅ CORRETTO
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box IMPARARE TUTTI (`p-4 bg-white rounded-2xl border-3 border-yellow-400`)
- Box esempio (`p-4 bg-cyan-50 rounded-lg`)
- Box da completare (`p-4 bg-gray-50 rounded-lg`)
- Tabella espressioni (`border border-cyan-400 bg-cyan-100`)
- Checkbox multipla con `data-correct-answer="true/false"`

### Correzioni fatte:
- base_color da blue a cyan (seed aggiornato)
- Box esercizi: rimosso bg/rounded/border wrapper
- Box IMPARARE TUTTI: border-3 border-yellow-400
- Tabelle: stile cyan coerente

---

## p178 - CONFRONTARE E ORDINARE NUMERI GRANDI (base_color: cyan) ✅ CORRETTO
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box IMPARARE TUTTI (`p-4 bg-white rounded-2xl border-3 border-yellow-400`)
- word-highlighter controller
- Grid 2 gruppi numeri (`grid grid-cols-1 md:grid-cols-2`)
- Box gruppo (`p-4 bg-gray-50 rounded-lg`)
- Input precedente/successivo con numero centrale (`bg-cyan-50`)
- Box ordinamento (`p-3 bg-white rounded-lg border border-gray-200`)
- Successioni con frecce e input (`rounded-full border-2 border-cyan-400`)

### Correzioni fatte:
- base_color da blue a cyan (seed aggiornato)
- Box esercizi: rimosso bg/rounded/border wrapper
- Box IMPARARE TUTTI: border-3 border-yellow-400
- Colori cyan consistenti

---

## p179 - NUMERI DECIMALI (1) (base_color: cyan) ✅ CORRETTO
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box IMPARARE TUTTI (`p-4 bg-white rounded-2xl border-3 border-yellow-400`)
- Tabella parte intera/decimale (`border border-cyan-400 bg-cyan-100/bg-green-100`)
- Layout 2 colonne (`grid grid-cols-1 md:grid-cols-2`)
- Box esempio composizione (`p-2 bg-cyan-50 rounded`)
- Esercizio frazioni con partial `_frazione`
- Tabella frazioni (`border border-cyan-400 bg-cyan-100`)

### Correzioni fatte:
- base_color da blue a cyan (seed aggiornato)
- Box esercizi: rimosso bg/rounded/border wrapper
- Box IMPARARE TUTTI: border-3 border-yellow-400
- Tabelle: header bg-cyan-100, celle bg-white, griglia border-cyan-400
- Esempio con bg-cyan-50

---

## p180 - NUMERI DECIMALI (2) (base_color: cyan) ✅ CORRETTO
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box IMPARARE TUTTI (`p-4 bg-white rounded-2xl border-3 border-yellow-400`)
- Grid 4 colonne (`grid grid-cols-2 md:grid-cols-4`)
- Box regola confronto decimali (`p-4 bg-pink-light rounded-3xl`)
- Lista con marker (`list-disc pl-6 marker:text-cyan-500`)
- Grid confronti con input (`p-2 bg-white rounded-lg`)
- Box ordinamento (`p-3 bg-white rounded-lg border border-gray-200`)
- Esempio evidenziato (`p-2 bg-cyan-50 rounded-lg`)
- Input precedente/successivo intero

### Correzioni fatte:
- base_color da blue a cyan (seed aggiornato)
- Box esercizi: rimosso bg/rounded/border wrapper
- Box IMPARARE TUTTI: border-3 border-yellow-400
- Colori cyan consistenti

---

## Note

- p171 è MODELLO INVALSI con base_color pink - esercizi tipo INVALSI con checkbox
- p172-p174 sono Educazione finanziaria con base_color pink - teoria con box colorati
- p175 è INDICE quaderno esercizi con base_color cyan - link navigazione
- p176-p180 sono ESERCIZI sui numeri con base_color cyan - esercizi interattivi con tabelle

## Riepilogo correzioni p176-p180

Tutte le pagine p176-p180 sono state corrette con:
1. **base_color**: da blue a cyan (seed aggiornato)
2. **Box esercizi**: rimosso wrapper con bg/rounded/border
3. **Box IMPARARE TUTTI**: `p-4 bg-white rounded-2xl border-3 border-yellow-400`
4. **Tabelle**: header `bg-cyan-100 text-gray-800`, celle `bg-white`, griglia `border-cyan-400`
5. **Colori**: tutti i riferimenti a `@pagina.base_color` sostituiti con `cyan` fisso dove necessario
