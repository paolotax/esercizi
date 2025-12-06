# Correzioni Box Pagine P121-P130

Documento di riferimento per i box e gli stili utilizzati nelle pagine nvi5_mat da p121 a p130.

---

## p121 - GEOMETRIA (base_color: pink)

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Nessun box colorato | sfondo bianco | Costruzione esagono e ottagono regolare |

**Elementi utilizzati:**
- `h2` con `font-bold italic text-<%= @pagina.base_color %>-600` per titoli sezione
- `ol` con `list-decimal pl-6` per liste numerate
- `grid grid-cols-1 md:grid-cols-2` per layout immagine/testo
- Immagini: `p121_01.jpg`, `p121_02.jpg`

**Correzioni:** Nessuna correzione necessaria

---

## p122 - GEOMETRIA (base_color: pink)

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Tabella misure superficie | header `bg-blue-100`, `bg-pink-200`, `bg-gray-100` | Multipli, unità, sottomultipli |
| Celle tabella | `bg-blue-50`, `bg-pink-100`, `bg-gray-50`, `bg-white` | Valori |
| Tabella misure agrarie | header `bg-pink-200`, celle `bg-white` | ha, a, ca |
| Container esercizi | `bg-orange-100` | Esercizi 1-2 |
| Tabella esercizio 1 | header `bg-blue-100`, celle `bg-white` | Inserisci misure |

**Elementi utilizzati:**
- `whitespace-nowrap` per numeri grandi
- `grid grid-cols-1 md:grid-cols-2` per layout
- `md:divide-x-2 md:divide-orange-300` per divisore esercizi
- Immagine: `p122_01.jpg`
- Partial: `quaderno_link` pagine [240]

**Correzioni:** Nessuna correzione necessaria

---

## p123 - GEOMETRIA (base_color: pink)

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Box definizione area | `bg-pink-light rounded-3xl` | L'area di un poligono... |
| Tabella formule | header `bg-gray-100`, celle `bg-white` | Poligono, da dove partire, formule |

**Elementi utilizzati:**
- `grid grid-cols-1 md:grid-cols-2` per intro
- Tabella con 3 colonne: poligono, spiegazione, formule
- `align-top` per celle tabella
- `text-pink-600 font-bold` per nomi poligoni e "Formule inverse"
- Immagini: `p123_01.jpg` - `p123_04.jpg`
- Partial: `quaderno_link` pagine [241, 242, 243, 244, 249, 250, 251]

**Correzioni:** Nessuna correzione necessaria

---

## p124 - GEOMETRIA (base_color: pink)

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Tabella formule | header `bg-gray-100`, celle `bg-white` | Trapezio, Triangolo |
| Container esercizi | `bg-orange-100` | Esercizio 1 |

**Elementi utilizzati:**
- Tabella continuazione da p123 (trapezio, triangolo)
- `grid grid-cols-2 md:grid-cols-3` per griglia figure esercizio
- Immagini PNG per figure esercizio: `output-1715938802124_*.png`
- Immagini: `p124_01.jpg`, `p124_02.jpg`
- Partial: `quaderno_link` pagine [245, 246, 249, 250, 251]

**Correzioni:** Nessuna correzione necessaria

---

## p125 - GEOMETRIA (base_color: pink)

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Box teoria | `bg-custom-blue rounded-lg` | Area poligoni regolari |
| Box formule | `bg-white rounded-lg` | A = (P × a) : 2, Formule inverse |
| Formula evidenziata | `text-pink-600 font-bold` | Area = Perimetro × apotema : 2 |
| Container esercizi | `bg-orange-100` | Esercizio 1 tabella |
| Tabella esercizio | header `bg-pink-100`, celle `bg-white` | Poligoni regolari |

**Elementi utilizzati:**
- `grid grid-cols-1 md:grid-cols-2` e `md:grid-cols-3` per layout
- Immagini: `p125_01.jpg`, `p125_02.jpg`
- Partial: `quaderno_link` pagine [247, 249, 250]

**Correzioni:** Nessuna correzione necessaria

---

## p126 - GEOMETRIA (base_color: pink)

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Box esempio guidato | `bg-custom-blue rounded-lg` | Scomposizione poligono |
| Container esercizi | `bg-orange-100` | Esercizio 1 |

**Elementi utilizzati:**
- `grid grid-cols-1 md:grid-cols-2` per layout esempio
- `list-disc pl-6 marker:text-<%= @pagina.base_color %>-500` per liste
- Immagini: `p126_01.jpg`, `p126_02.jpg`
- Partial: `quaderno_link` pagine [250]

**Correzioni:** Nessuna correzione necessaria

---

## p127 - GEOMETRIA (base_color: pink)

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Box teoria cerchio | `bg-custom-blue rounded-lg` | Area del cerchio |
| Box formule | `bg-white rounded-lg` | 3 formule equivalenti |
| Container esercizi | `bg-orange-100` | Esercizio 1 tabella |
| Tabella esercizio | header `bg-pink-100`, celle `bg-white` | raggio, diametro, circonferenza, Area |

**Elementi utilizzati:**
- `grid grid-cols-1 md:grid-cols-2` e `md:grid-cols-3` per layout
- `text-pink-600` per formule evidenziate
- Immagini: `p127_01.jpg`, `p127_02.jpg`, `p127_03.jpg`
- Partial: `quaderno_link` pagine [248, 249, 250, 251]

**Correzioni:** Nessuna correzione necessaria

---

## p128 - GEOMETRIA (base_color: pink)

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Nessun box colorato | sfondo bianco | Approssimazioni progressive |

**Elementi utilizzati:**
- `grid grid-cols-1 md:grid-cols-2` per layout
- Box unità misura: `border border-gray-400 w-6 h-6` (Q) e `w-4 h-4` (q)
- Immagini: `output-1715938802128_683_203_255_218.png`, `p128_01.jpg`, `p128_02.jpg`

**Correzioni:** Nessuna correzione necessaria

---

## p129 - ESERCIZI (base_color: orange)

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Container esercizi | `bg-orange-100` | Wrapper tutti esercizi |
| Box IMPARARE TUTTI | `bg-white rounded-2xl border-3 border-blue-500` | Esercizi 1-2 |
| Divisore interno | `md:divide-x-2 md:divide-blue-300` | Separa es.1 e es.2 |
| Tabella esercizio 7 | celle `bg-white` | Poligoni regolari con immagini PNG |

**Elementi utilizzati:**
- `-mx-4 md:-mx-6 -mt-4 md:-mt-6` per box IMPARARE TUTTI a margini negativi
- `grid grid-cols-1 md:grid-cols-2` per layout esercizi
- Immagini PNG per poligoni: `output-1715938802129_*.png`
- Immagini: `p129_01.jpg`, `p129_02.jpg`, `p129_03.jpg`, `p129_04.jpg`

**Correzioni:** Nessuna correzione necessaria

---

## p130 - PROBLEMI (base_color: pink)

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Box problema 1 | `bg-orange-100 rounded-lg` | Cameretta battiscopa |
| Box problema 2 | `bg-orange-100 rounded-lg` | Fontana bordo marmo |
| Box problema 3 | `bg-orange-100 rounded-lg` | Recinzione giardino |

**Elementi utilizzati:**
- `grid grid-cols-1 md:grid-cols-2` per layout problema/immagine
- `md:order-1` e `md:order-2` per invertire ordine su desktop (problema 2)
- Immagini: `p130_01.jpg`, `p130_02.jpg`, `p130_03.jpg`

**Correzioni:** Nessuna correzione necessaria

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

## Colori Dinamici Usati

- `text-<%= @pagina.base_color %>-500` - bullet points, frecce
- `text-<%= @pagina.base_color %>-600` - titoli h2 italic
- `marker:text-<%= @pagina.base_color %>-500` - marker liste
- `md:divide-<%= @pagina.base_color %>-300` - divisori (solo p122)

## Partial Utilizzati

- `shared/page_header` - tutte le pagine
- `shared/exercise_controls` - tutte le pagine
- `shared/quaderno_link` - p122, p123, p124, p125, p126, p127
