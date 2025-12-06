# Correzioni Box - Pagine 151-160 (nvi5_mat)

## Riepilogo Box Utilizzati per Pagina

### p151 - UNO SPAZIO PER GIOVANI (PROBLEMI AL CENTRO)
- **Box lettera**: `border-2 border-gray-300 rounded-lg bg-white` - Lettera del Presidente dell'Associazione
- **Catalogo**: Griglia con `border border-gray-300 rounded-lg` - Tabelle prodotti (giochi movimento, tavolo, arredamento)
- **Domanda**: `bg-pink-light rounded-lg` - Box rosa chiaro per la domanda principale
- **Area risposta**: `bg-gray-50 rounded-lg` - Textarea per risposta libera

### p152 - UNA PESATA DIFFICILE (PROBLEMI AL CENTRO)
- **Info pesate**: Griglia `bg-blue-50`, `bg-green-50`, `bg-yellow-50`, `bg-orange-50`, `bg-purple-50` - Box colorati per le pesate degli animali
- **Domanda**: `bg-pink-light rounded-lg` - Box rosa chiaro per la domanda
- **Area risposta**: `bg-gray-50 rounded-lg` - Textarea per risposta

### p153 - UNA QUESTIONE DI TEMPI (PROBLEMI AL CENTRO)
- **Tabella orari**: `border-collapse border border-gray-400` - Orario traghetti Napoli-Capri
- **Domanda**: `bg-pink-light rounded-lg` - Box rosa chiaro
- **Area risposta**: `bg-gray-50 rounded-lg` - Textarea per risposta

### p154 - L'ALLENAMENTO (PROBLEMI AL CENTRO)
- **Domande**: `bg-pink-light rounded-lg space-y-3` - Box rosa con domande multiple
- **Area risposta**: `bg-gray-50 rounded-lg` - Textarea per risposta

### p155 - LA STELLA (PROBLEMI AL CENTRO)
- **Domanda**: `bg-pink-light rounded-lg` - Box rosa chiaro per la domanda sull'area
- **Area risposta**: `bg-gray-50 rounded-lg` - Textarea per calcolo e ragionamento

### p156 - RELAZIONI, DATI E PREVISIONI (PAROLE AL CENTRO)
- **Box teoria**: `bg-custom-blue rounded-lg` - Sfondo celeste con grafici istogramma/ideogramma
- **Box grafici interni**: `bg-white rounded-lg p-4 border-2 border-pink-400` - Box bianchi per grafici
- **Box esercizi**: `bg-orange-100 rounded-lg` - Sfondo arancione per esercizio "completa"

### p157 - RELAZIONI, DATI E PREVISIONI (PAROLE AL CENTRO)
- **Box teoria AREOGRAMMA QUADRATO**: `bg-custom-blue rounded-lg` + `bg-white rounded-lg p-4 border-2 border-pink-400`
- **Box teoria AREOGRAMMA CIRCOLARE**: `bg-custom-blue rounded-lg` + `bg-white rounded-lg p-4 border-2 border-pink-400`
- **Box esercizio Collega**: `bg-orange-100 rounded-lg`
- **Box esercizio Osserva**: `bg-orange-100 rounded-lg` con radio button

### p158 - CLASSIFICARE (RELAZIONI, DATI E PREVISIONI)
- **Box teoria**: `bg-custom-blue rounded-lg` - Introduzione classificazione
- **Box regola**: `bg-white p-3 rounded-lg border border-pink-300` - Definizione "Classificare"
- **Diagramma Eulero-Venn**: `bg-orange-100 rounded-lg` - Esercizio con immagine
- **Diagramma Carroll**: `bg-orange-100 rounded-lg` - Tabella con input
- **Box ESERCIZI**: `bg-orange-100 rounded-lg` - Esercizio quaderni cartoleria
- **Tabella Carroll quaderni**: `border-collapse border border-gray-400` con header `bg-pink-100`
- **Quaderno link**: Partial per collegamento p. 258

### p159 - STABILIRE RELAZIONI (RELAZIONI, DATI E PREVISIONI)
- **Box esercizio frecce**: `bg-orange-100 rounded-lg` - Metti in relazione le persone
- **Box esercizio frecce doppio/metà**: `bg-orange-100 rounded-lg` - Freccia rossa e blu con radio
- **Box esercizio cugina**: `bg-orange-100 rounded-lg` - Relazione simmetrica
- **Box ESERCIZI**: `bg-orange-100 rounded-lg` - Relazioni con checkbox per simmetria

### p160 - CLASSIFICAZIONI E RELAZIONI (ESERCIZI)
- **Box IMPARARE TUTTI**: `bg-white rounded-2xl -mx-4 md:-mx-6 -mt-4 md:-mt-6 mb-6 border-3 border-blue-500` - Es. 1 con diagramma Eulero-Venn
- **Tabella vacanze**: `border-collapse border border-gray-400` con header `bg-pink-100`
- **Box problema età**: `bg-white rounded-lg border border-gray-300` - Testo problema
- **Area disegno schema**: `bg-gray-50 rounded-lg` con `border-2 border-dashed border-gray-300`

---

## Pattern Box Comuni Utilizzati

| Tipo Box | Classe Tailwind | Uso |
|----------|-----------------|-----|
| Teoria/Introduzione | `bg-custom-blue rounded-lg` | Spiegazioni iniziali |
| Regola/Definizione | `bg-white p-3 rounded-lg border border-pink-300` | Box regole |
| Domanda principale | `bg-pink-light rounded-lg` | Domande da rispondere |
| Esercizi | `bg-orange-100 rounded-lg` | Container esercizi |
| IMPARARE TUTTI | `bg-white rounded-2xl border-3 border-blue-500` | Primo esercizio evidenziato |
| Area risposta | `bg-gray-50 rounded-lg` | Textarea/input libero |
| Tabella | `border-collapse border border-gray-400` | Tabelle dati |
| Header tabella | `bg-pink-100 border border-gray-400` | Intestazioni tabelle |
| Celle tabella | `bg-white border border-gray-400` | Celle dati |

---

## Note Implementazione

1. **Pagine 151-155**: Sono "PROBLEMI AL CENTRO" - problemi aperti senza risposta unica
2. **Pagine 156-157**: Sono "PAROLE AL CENTRO" - teoria sui tipi di grafici
3. **Pagine 158-159**: Sono "RELAZIONI, DATI E PREVISIONI" - classificazione e relazioni
4. **Pagina 160**: È "ESERCIZI" - esercizi con base_color orange

5. **Immagini utilizzate**:
   - p151: Catalogo oggetti (output-*.png)
   - p152: p152_01.jpg (bilance animali)
   - p154: p154_01.jpg, p154_02.jpg (campi basket)
   - p155: output-*.png (griglia)
   - p156: p156_01.jpg, p156_02.jpg (grafici)
   - p158: p158_01.jpg (Eulero-Venn)
   - p159: p159_01.jpg, output-*.png (frecce relazioni)
   - p160: p160_01.jpg, p160_02.jpg, p160_03.jpg, p160_04.jpg (diagrammi)

6. **Quaderno link**: Solo p158 ha riferimento al Quaderno esercizi (p. 258)
