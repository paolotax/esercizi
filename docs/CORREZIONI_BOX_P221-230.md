# CORREZIONI BOX P221-P230

## Procedura

Quando eseguo le correzioni:
- Se modifico **titolo** o **sottotitolo** → aggiorno anche il seed
- Se modifico **base_color** → aggiorno anche il seed
- Alla fine delle correzioni → riscrivo questo file con le modifiche fatte

---

## p221 - MISURE DI MASSA (base_color: cyan)
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box teoria misure massa (`bg-custom-blue`)
- Box IMPARARE TUTTI (`border-3 border-yellow-400`)
- Tabelle scomposizione/composizione (`border-cyan-400`)
- Input per equivalenze e operazioni

### Correzioni fatte:
- Box teoria: da `rounded-lg` a `rounded-3xl`, aggiunto `md:p-6`
- Tabelle header: da `bg-custom-blue-light` a `bg-white`, da `text-cyan-700` a `text-cyan-600`
- Unità fondamentale: da `bg-cyan-200`/`bg-custom-blue-light` a `bg-gray-200`
- Testo unità fondamentale: aggiunto `text-cyan-600`

---

## p222 - LUNGHEZZA, CAPACITÀ E MASSA (base_color: cyan)
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box IMPARARE TUTTI (`border-3 border-yellow-400`)
- Esercizi scrittura in lettere
- Confronti con simboli >, <, =
- Vero/Falso con radio button

### Correzioni fatte:
- Vero/Falso: rimossi `border border-gray-200 rounded` (10 righe)

---

## p223 - L'EURO (base_color: cyan)
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box teoria euro (`bg-custom-blue`)
- Box IMPARARE TUTTI (`border-3 border-yellow-400`)
- Tabella formazione euro
- Problemi con pagamento/resto

### Correzioni fatte:
- Tabella: centrata con `flex justify-center`, rimosso `w-full`

---

## p224 - IL COMMERCIO (base_color: cyan)
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box teoria formule commercio (`bg-custom-blue`)
- Box IMPARARE TUTTI (`border-3 border-yellow-400`)
- Tabella spesa/ricavo/guadagno
- Problemi commercio

### Correzioni fatte:
- Box teoria: da `rounded-lg` a `rounded-2xl`, aggiunto `w-fit mx-auto`
- Formule: rimossi `p-3 bg-white rounded`, aumentato gap a `gap-6`
- Layout problemi: ristrutturato con `md:divide-x-2 divide-cyan-300`
- Box problemi: rimosso `bg-custom-blue-light rounded-2xl`, semplificato layout

---

## p225 - MISURE DI TEMPO (base_color: cyan)
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box teoria misure tempo (`bg-custom-blue`)
- Box IMPARARE TUTTI (`border-3 border-yellow-400`)
- Tabelle equivalenze tempo
- Vero/Falso con frazioni
- Operazioni con tempi

### Correzioni fatte:
- Box teoria: da `rounded-lg` a `rounded-3xl`, aggiunto `md:p-6`
- Tabelle header: da `bg-custom-blue-light` a `bg-white`, da `text-cyan-700` a `text-cyan-600`
- Unità fondamentale: da `bg-cyan-200`/`bg-custom-blue-light` a `bg-gray-200`
- Testo unità fondamentale: aggiunto `text-cyan-600`
- Vero/Falso: rimossi `border border-gray-200 rounded`

---

## p226 - PROBLEMI DI MISURA E DI COMPRAVENDITA (base_color: cyan)
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box IMPARARE TUTTI (`border-3 border-yellow-400`)
- 11 problemi testuali numerati
- Da risolvere sul quaderno

### Correzioni fatte:
- Rimossa sezione/titolo "Problemi con le misure"
- Layout: ristrutturato con grid e `md:divide-x-2 divide-cyan-300`
- Problemi: rimosso `bg-custom-blue-light rounded-2xl`, testo semplificato
- Aggiunti campi input per risposte numeriche con unità di misura

---

## p227 - LE MISURE (base_color: cyan)
**Sottotitolo:** RIPASSO

### Box utilizzati:
- Box riassuntivo misure (`bg-custom-blue`)
- Box IMPARARE TUTTI (`border-3 border-yellow-400`)
- Equivalenze miste
- Operazioni con tempi
- Problemi compravendita

### Correzioni fatte:
- Box problemi: da `bg-custom-blue-light` a `bg-white border border-cyan-300`
- Aggiunti campi input per risposte (€ 1,90 e € 2,96)

---

## p228 - RETTE, SEMIRETTE E SEGMENTI (base_color: cyan)
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box IMPARARE TUTTI (`border-3 border-yellow-400`)
- Immagini geometriche (rette, segmenti, semirette)
- Esercizi riconoscimento linee
- Rette incidenti/parallele

### Correzioni fatte:
- Tabella: centrata con `flex justify-center`, rimosso `w-full`

---

## p229 - ANGOLI (base_color: cyan)
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box IMPARARE TUTTI (`border-3 border-yellow-400`)
- Vero/Falso su tipi di angoli
- Immagini angoli
- Angoli convessi/concavi
- Misurazione angoli

### Correzioni fatte:
- Box angoli: rimossi `border border-gray-200 rounded-lg` (4 box)

---

## p230 - SIMMETRIA (base_color: cyan)
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- Box IMPARARE TUTTI (`border-3 border-yellow-400`)
- Esercizi visivi assi di simmetria
- Costruzione figure simmetriche
- Immagini da completare

### Correzioni da fare:
NESSUNA

---

## Note

- p227 è pagina RIPASSO
- p221-p226, p228-p230 sono pagine ESERCIZI
- Stile tabelle: `border-cyan-400`, `bg-cyan-100`
- Box IMPARARE TUTTI: `border-3 border-yellow-400`
- Box teoria: `bg-custom-blue rounded-lg`
- Tutti gli esercizi usano `numero_esercizio_badge`

## Riepilogo correzioni

- **p221**: Uniformato stile tabella teoria (rounded-3xl, header bg-white, unità fondamentale bg-gray-200)
- **p222**: Rimossi bordi dai Vero/Falso
- **p223**: Centrata tabella euro
- **p224**: Semplificato box teoria, ristrutturato layout problemi con divider
- **p225**: Uniformato stile tabella teoria come p221, rimossi bordi V/F
- **p226**: Ristrutturato layout problemi, aggiunti campi input risposte
- **p227**: Cambiato stile box problemi (bg-white + border), aggiunti input
- **p228**: Centrata tabella
- **p229**: Rimossi bordi dai box angoli
- **p230**: NESSUNA MODIFICA
