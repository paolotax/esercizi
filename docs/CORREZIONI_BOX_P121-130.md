# CORREZIONI BOX P121-P130

## Procedura

Quando eseguo le correzioni:
- Se modifico **titolo** o **sottotitolo** → aggiorno anche il seed
- Se modifico **base_color** → aggiorno anche il seed
- Alla fine delle correzioni → riscrivo questo file con le modifiche fatte

---

## p121 - ESAGONO E OTTAGONO REGOLARI (base_color: yellow)
**Sottotitolo:** LABORATORIO

### Box utilizzati:
- **h2** (`font-bold italic text-blue-600`) - Titoli sezione (blu fisso per LABORATORIO)
- **ol** con pallini blu (`bg-blue-500 text-white rounded-full`) - Marker numerati bianchi su sfondo blu
- Immagini: `p121_01.jpg`, `p121_02.jpg` - Posizionate SOTTO il testo

### Correzioni da fare:


---

## p122 - LE MISURE DI SUPERFICIE (base_color: pink)
**Sottotitolo:** GEOMETRIA

### Box utilizzati:
- **Tabella misure superficie** (header `bg-blue-100`, `bg-pink-200`, `bg-gray-100`) - Multipli, unità, sottomultipli
- **Celle tabella** (`bg-blue-50`, `bg-pink-100`, `bg-gray-50`, `bg-white`) - Valori
- **Tabella misure agrarie** (header `bg-pink-200`, celle `bg-white`) - ha, a, ca
- **Container esercizi** (`bg-orange-100`) - Esercizi 1-2
- **Tabella esercizio 1** (header `bg-blue-100`, celle `bg-white`) - Inserisci misure
- `whitespace-nowrap` per numeri grandi
- `grid grid-cols-1 md:grid-cols-2` per layout
- `md:divide-x-2 md:divide-orange-300` per divisore esercizi
- Immagine: `p122_01.jpg`
- Partial: `quaderno_link` pagine [240]

### Correzioni da fare:


---

## p123 - L'AREA DEI PARALLELOGRAMMI (base_color: pink)
**Sottotitolo:** GEOMETRIA

### Box utilizzati:
- **Box definizione area** (`bg-pink-light rounded-3xl`) - L'area di un poligono...
- **Tabella formule** (header `bg-gray-100`, celle `bg-white`) - Poligono, da dove partire, formule
- `grid grid-cols-1 md:grid-cols-2` per intro
- `align-top` per celle tabella
- `text-pink-600 font-bold` per nomi poligoni e "Formule inverse"
- Immagini: `p123_01.jpg` - `p123_04.jpg`
- Partial: `quaderno_link` pagine [241, 242, 243, 244, 249, 250, 251]

### Correzioni da fare:


---

## p124 - L'AREA DEL TRAPEZIO E DEL TRIANGOLO (base_color: pink)
**Sottotitolo:** GEOMETRIA

### Box utilizzati:
- **Tabella formule** (header `bg-gray-100`, celle `bg-white`) - Trapezio, Triangolo
- **Container esercizi** (`bg-orange-100`) - Esercizio 1
- `grid grid-cols-2 md:grid-cols-3` per griglia figure esercizio
- Immagini PNG per figure esercizio: `output-1715938802124_*.png`
- Immagini: `p124_01.jpg`, `p124_02.jpg`
- Partial: `quaderno_link` pagine [245, 246, 249, 250, 251]

### Correzioni da fare:


---

## p125 - L'AREA DEI POLIGONI REGOLARI (base_color: pink)
**Sottotitolo:** GEOMETRIA

### Box utilizzati:
- **Box teoria** (`bg-custom-blue rounded-lg`) - Area poligoni regolari
- **Box formule** (`bg-white rounded-lg`) - A = (P × a) : 2, Formule inverse
- **Formula evidenziata** (`text-pink-600 font-bold`) - Area = Perimetro × apotema : 2
- **Container esercizi** (`bg-orange-100`) - Esercizio 1 tabella
- **Tabella esercizio** (header `bg-pink-100`, celle `bg-white`) - Poligoni regolari
- `grid grid-cols-1 md:grid-cols-2` e `md:grid-cols-3` per layout
- Immagini: `p125_01.jpg`, `p125_02.jpg`
- Partial: `quaderno_link` pagine [247, 249, 250]

### Correzioni da fare:


---

## p126 - L'AREA DI POLIGONI IRREGOLARI (base_color: pink)
**Sottotitolo:** GEOMETRIA

### Box utilizzati:
- **Box esempio guidato** (`bg-custom-blue rounded-lg`) - Scomposizione poligono
- **Container esercizi** (`bg-orange-100`) - Esercizio 1
- `grid grid-cols-1 md:grid-cols-2` per layout esempio
- `list-disc pl-6 marker:text-pink-500` per liste
- Immagini: `p126_01.jpg`, `p126_02.jpg`
- Partial: `quaderno_link` pagine [250]

### Correzioni da fare:


---

## p127 - L'AREA DEL CERCHIO (base_color: pink)
**Sottotitolo:** GEOMETRIA

### Box utilizzati:
- **Box teoria cerchio** (`bg-custom-blue rounded-lg`) - Area del cerchio
- **Box formule** (`bg-white rounded-lg`) - 3 formule equivalenti
- **Container esercizi** (`bg-orange-100`) - Esercizio 1 tabella
- **Tabella esercizio** (header `bg-pink-100`, celle `bg-white`) - raggio, diametro, circonferenza, Area
- `grid grid-cols-1 md:grid-cols-2` e `md:grid-cols-3` per layout
- `text-pink-600` per formule evidenziate
- Immagini: `p127_01.jpg`, `p127_02.jpg`, `p127_03.jpg`
- Partial: `quaderno_link` pagine [248, 249, 250, 251]

### Correzioni da fare:


---

## p128 - LABORATORIO L'AREA DELLE FIGURE IRREGOLARI (base_color: yellow)
**Sottotitolo:** LABORATORIO

### Box utilizzati:
- `grid grid-cols-1 md:grid-cols-2` per layout
- **Box unità misura**: `border border-gray-400 w-6 h-6` (Q) e `w-4 h-4` (q)
- Immagini: `output-1715938802128_683_203_255_218.png`, `p128_01.jpg`, `p128_02.jpg`

### Correzioni da fare:


---

## p129 - ESERCIZI L'AREA (base_color: orange)
**Sottotitolo:** ESERCIZI

### Box utilizzati:
- **Container esercizi** (`bg-orange-100`) - Wrapper tutti esercizi
- **Box IMPARARE TUTTI** (`bg-white rounded-2xl border-3 border-blue-500`) - Esercizi 1-2
- **Divisore interno** (`md:divide-x-2 md:divide-blue-300`) - Separa es.1 e es.2
- **Tabella esercizio 7** (celle `bg-white`) - Poligoni regolari con immagini PNG
- `-mx-4 md:-mx-6 -mt-4 md:-mt-6` per box IMPARARE TUTTI a margini negativi
- `grid grid-cols-1 md:grid-cols-2` per layout esercizi
- Immagini PNG per poligoni: `output-1715938802129_*.png`
- Immagini: `p129_01.jpg`, `p129_02.jpg`, `p129_03.jpg`, `p129_04.jpg`

### Correzioni da fare:


---

## p130 - LABORATORIO PERIMETRI E AREE NEL QUOTIDIANO (base_color: yellow)
**Sottotitolo:** PROBLEMI

### Box utilizzati:
- **Box problema 1** (`bg-orange-100 rounded-lg`) - Cameretta battiscopa
- **Box problema 2** (`bg-orange-100 rounded-lg`) - Fontana bordo marmo
- **Box problema 3** (`bg-orange-100 rounded-lg`) - Recinzione giardino
- `grid grid-cols-1 md:grid-cols-2` per layout problema/immagine
- `md:order-1` e `md:order-2` per invertire ordine su desktop (problema 2)
- Immagini: `p130_01.jpg`, `p130_02.jpg`, `p130_03.jpg`

### Correzioni da fare:


---

## Riepilogo Box Utilizzati

| Tipo Box | Classi Tailwind | Pagine |
|----------|-----------------|--------|
| Teoria celeste | `bg-custom-blue rounded-lg` | p125, p126, p127 |
| Regola rosa chiaro | `bg-pink-light rounded-3xl` | p123 |
| Esercizi arancione | `bg-orange-100 rounded-lg` | p122, p124, p125, p126, p127, p129, p130 |
| IMPARARE TUTTI | `bg-white rounded-2xl border-3 border-blue-500` | p129 |
| Tabella header rosa | `bg-pink-100` o `bg-pink-200` | p122, p125, p127 |
| Tabella header blu | `bg-blue-100` | p122 |
| Tabella header grigio | `bg-gray-100` | p123, p124 |
| Celle tabella | `bg-white` | tutte |

---

## Colori Dinamici Usati

- `text-<%= @pagina.base_color %>-500` - bullet points, frecce
- `text-<%= @pagina.base_color %>-600` - titoli h2 italic
- `marker:text-<%= @pagina.base_color %>-500` - marker liste
- `md:divide-<%= @pagina.base_color %>-300` - divisori (solo p122)

---

## Partial Utilizzati

- `shared/page_header` - tutte le pagine
- `shared/exercise_controls` - tutte le pagine
- `shared/quaderno_link` - p122, p123, p124, p125, p126, p127

---

## Note

- p121, p128, p130 sono LABORATORIO con base_color yellow
- p129 è ESERCIZI con base_color orange
- Le altre pagine sono GEOMETRIA con base_color pink
