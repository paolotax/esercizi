# CORREZIONI BOX P151-P160

## Procedura

Quando eseguo le correzioni:
- Se modifico **titolo** o **sottotitolo** → aggiorno anche il seed
- Se modifico **base_color** → aggiorno anche il seed
- Alla fine delle correzioni → riscrivo questo file con le modifiche fatte

---

## p151 - UNO SPAZIO PER GIOVANI (base_color: pink)
**Sottotitolo:** PROBLEMI AL CENTRO

### Box utilizzati:
- **Box lettera**: `border-2 border-gray-300 rounded-lg bg-white` - Lettera del Presidente dell'Associazione
- **Catalogo**: Griglia con `border border-gray-300 rounded-lg` - Tabelle prodotti (giochi movimento, tavolo, arredamento)
- **Domanda**: `bg-pink-light rounded-lg` - Box rosa chiaro per la domanda principale
- **Area risposta**: `bg-gray-50 rounded-lg` - Textarea per risposta libera

### Correzioni da fare:


---

## p152 - UNA PESATA DIFFICILE (base_color: pink)
**Sottotitolo:** PROBLEMI AL CENTRO

### Box utilizzati:
- **Info pesate**: Griglia `bg-blue-50`, `bg-green-50`, `bg-yellow-50`, `bg-orange-50`, `bg-purple-50` - Box colorati per le pesate degli animali
- **Domanda**: `bg-pink-light rounded-lg` - Box rosa chiaro per la domanda
- **Area risposta**: `bg-gray-50 rounded-lg` - Textarea per risposta

### Correzioni da fare:


---

## p153 - UNA QUESTIONE DI TEMPI (base_color: pink)
**Sottotitolo:** PROBLEMI AL CENTRO

### Box utilizzati:
- **Tabella orari**: `border-collapse border border-gray-400` - Orario traghetti Napoli-Capri
- **Domanda**: `bg-pink-light rounded-lg` - Box rosa chiaro
- **Area risposta**: `bg-gray-50 rounded-lg` - Textarea per risposta

### Correzioni da fare:


---

## p154 - L'ALLENAMENTO (base_color: pink)
**Sottotitolo:** PROBLEMI AL CENTRO

### Box utilizzati:
- **Domande**: `bg-pink-light rounded-lg space-y-3` - Box rosa con domande multiple
- **Area risposta**: `bg-gray-50 rounded-lg` - Textarea per risposta

### Correzioni da fare:


---

## p155 - LA STELLA (base_color: pink)
**Sottotitolo:** PROBLEMI AL CENTRO

### Box utilizzati:
- **Domanda**: `bg-pink-light rounded-lg` - Box rosa chiaro per la domanda sull'area
- **Area risposta**: `bg-gray-50 rounded-lg` - Textarea per calcolo e ragionamento

### Correzioni da fare:


---

## p156 - RELAZIONI, DATI E PREVISIONI (base_color: pink)
**Sottotitolo:** PAROLE AL CENTRO

### Box utilizzati:
- **Box teoria**: `bg-custom-blue rounded-lg` - Sfondo celeste con grafici istogramma/ideogramma
- **Box grafici interni**: `bg-white rounded-lg p-4 border-2 border-pink-400` - Box bianchi per grafici
- **Box esercizi**: `bg-orange-100 rounded-lg` - Sfondo arancione per esercizio "completa"

### Correzioni da fare:


---

## p157 - RELAZIONI, DATI E PREVISIONI (base_color: pink)
**Sottotitolo:** PAROLE AL CENTRO

### Box utilizzati:
- **Box teoria AREOGRAMMA QUADRATO**: `bg-custom-blue rounded-lg` + `bg-white rounded-lg p-4 border-2 border-pink-400`
- **Box teoria AREOGRAMMA CIRCOLARE**: `bg-custom-blue rounded-lg` + `bg-white rounded-lg p-4 border-2 border-pink-400`
- **Box esercizio Collega**: `bg-orange-100 rounded-lg`
- **Box esercizio Osserva**: `bg-orange-100 rounded-lg` con radio button

### Correzioni da fare:


---

## p158 - CLASSIFICARE (base_color: pink)
**Sottotitolo:** RELAZIONI, DATI E PREVISIONI

### Box utilizzati:
- **Box teoria**: `bg-white border-3 border-blue-500 rounded-lg relative` - Con regola in posizione assoluta
- **Box regola**: `absolute -top-4 right-4 bg-white px-4 py-2 rounded-3xl shadow-sm border border-gray-200` - Attaccato in alto a destra
- **Diagramma Eulero-Venn + Carroll**: Grid 2 colonne con divider `md:divide-x-2 md:divide-<%= @pagina.base_color %>-300`
- **Titoli con pallino**: `<span class="inline-block w-3 h-3 rounded-full bg-<%= @pagina.base_color %>-500 mr-2"></span>`
- **Tabella Carroll**: Header MULTIPLI `bg-red-100 text-red-600`, Header NUMERI PARI/DISPARI `bg-cyan-100 text-cyan-600`
- **Diagramma ad albero**: Sezione con legenda R/NR/Q/NQ/G/NG
- **Box ESERCIZI**: `bg-orange-100 rounded-lg` (senza header ESERCIZI)
- **Quaderno link**: Partial per collegamento p. 258

### Correzioni fatte: ✅
- Box teoria bg-white border-3 border-blue-500
- Box regola rounded-3xl con margine negativo attaccato in alto a destra
- Diagramma Eulero-Venn e Carroll affiancati con divider
- Titoli con pallino span base_color
- Tabella Carroll: header MULTIPLI rossi, righe NUMERI PARI/DISPARI azzurri
- Aggiunto box diagramma ad albero con legenda
- Rimosso header ESERCIZI

---

## p159 - STABILIRE RELAZIONI (base_color: pink)
**Sottotitolo:** RELAZIONI, DATI E PREVISIONI

### Box utilizzati:
- **Box esercizio 1**: Nessuno sfondo, no rounded, no padding - Solo titolo con pallino base_color
- **Box esercizio 2**: Flex con immagine a sinistra (`md:flex-row`) e testo a destra
- **Box esercizio 3**: Flex con immagine a destra (`md:flex-row-reverse`) e testo a sinistra
- **Box ESERCIZI**: `bg-orange-100 rounded-lg` (senza header ESERCIZI) - Relazioni con checkbox per simmetria

### Correzioni fatte: ✅
- Box 1 senza bg, rounded, padding - titolo con pallino span base_color
- Box 2 flex con immagine a sinistra e testo a destra
- Box 3 flex con immagine a destra e testo a sinistra
- Rimosso header ESERCIZI

---

## p160 - CLASSIFICAZIONI E RELAZIONI (base_color: pink)
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- **Layout 2 colonne**: es 1-2 sinistra, es 3-4-5-6 destra con `md:divide-x-2 md:divide-orange-300`
- **Box IMPARARE TUTTI**: `bg-white rounded-2xl border-3 border-blue-500` - Es. 1 con diagramma Eulero-Venn
- **Numeri con pallini**: `text-<%= @pagina.base_color %>-500` per i separatori
- **Tabella vacanze**: header "bambini" `bg-white`, header "mare/montagna" `bg-cyan-100`, celle `bg-white`, bordi `border-cyan-400`
- **Esercizio 6**: testo senza box, risposte su grid 2 colonne `grid grid-cols-2 gap-2`

### Correzioni fatte: ✅
- Layout 2 colonne con divider
- Pallini colorati nel box IMPARARE TUTTI
- Tabella es.2 con header bambini bianco, altri azzurri, celle bianche
- Immagine es.2 sotto la tabella centrata
- Es.6 risposte su grid 2 colonne


---

## Riepilogo Box Utilizzati

| Tipo Box | Classe Tailwind | Uso |
|----------|-----------------|-----|
| Teoria/Introduzione | `bg-custom-blue rounded-lg` | Spiegazioni iniziali |
| Teoria con bordo | `bg-white border-3 border-blue-500 rounded-lg` | Box teoria p158 |
| Regola/Definizione | `bg-white rounded-3xl shadow-sm border border-gray-200` | Box regole |
| Domanda principale | `bg-pink-light rounded-lg` | Domande da rispondere |
| Esercizi | `bg-orange-100 rounded-lg` | Container esercizi |
| IMPARARE TUTTI | `bg-white rounded-2xl border-3 border-blue-500` | Primo esercizio evidenziato |
| Area risposta | `bg-gray-50 rounded-lg` | Textarea/input libero |
| Tabella | `border-collapse border border-gray-400` | Tabelle dati |
| Header tabella rosa | `bg-pink-100 border border-gray-400` | Intestazioni tabelle |
| Header tabella rosso | `bg-red-100 text-red-600` | Header MULTIPLI |
| Header tabella cyan | `bg-cyan-100 text-cyan-600` | Header NUMERI PARI/DISPARI |
| Celle tabella | `bg-white border border-gray-400` | Celle dati |

---

## Note

- Le pagine p151-p155 sono "PROBLEMI AL CENTRO" - problemi aperti senza risposta unica
- Le pagine p156-p157 sono "PAROLE AL CENTRO" - teoria sui tipi di grafici
- Le pagine p158-p159 sono "RELAZIONI, DATI E PREVISIONI" - classificazione e relazioni
- La pagina p160 è "ESERCIZI" - esercizi con base_color pink (non orange come le altre pagine ESERCIZI)
- Solo p158 ha riferimento al Quaderno esercizi (p. 258)
