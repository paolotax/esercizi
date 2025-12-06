# Riepilogo Box Colorati - Pagine 131-140

## Legenda Tipi Box

| Tipo | Classe CSS | Uso Tipico |
|------|-----------|------------|
| Esercizi | `bg-orange-100` | Sezione esercizi |
| Teoria rosa | `bg-pink-light` | Spiegazioni, regole |
| Teoria celeste | `bg-custom-blue` | Definizioni, info |
| IMPARARE TUTTI | `bg-white border-3 border-blue-500` | Primo esercizio evidenziato |
| Tabella header | `bg-<color>-500 text-white` | Header tabelle |

---

## p131 - LABORATORIO (base_color: yellow) ✅

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Esercizio 4 | `bg-custom-blue` | Problema parete camera - COMPLETATO con risposte |
| Esercizio 5 | `bg-custom-blue` | Problema finestra LIM - COMPLETATO con risposte |
| Esercizio 6 | `bg-custom-blue` | Problema piastrelle cucina - COMPLETATO con risposte |
| Immagini | fuori dai box | Allineate a sinistra/destra |

**Correzioni:** ✅ FATTO
---

## p132 - MAPPA (base_color: cyan) ✅

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Header tabella | `bg-cyan-500` | POLIGONO / PERIMETRO / AREA |
| Righe tabella | `bg-white` | Formule per ogni poligono |
| Celle Perimetro | `text-left` | Allineate a sinistra |

**Correzioni:**


---

## p133 - MAPPA (base_color: cyan) ✅

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Sezione CIRCONFERENZA | `bg-white` + badge blu | Container principale |
| Sezione CERCHIO | `bg-white` + badge blu | Container principale |
| Sottotitoli | `bg-cyan-500 text-white rounded-full w-fit` | CHE COS'È, COME SI CALCOLA... |
| Box interni | `border-2 border-cyan-400 w-fit mx-auto` | Definizioni e formule |

**Correzioni:** ✅ FATTO - box w-fit centrati

---

## p134 - GEOMETRIA (base_color: pink) ✅

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Titolo "I poliedri" | fuori dal box | Titolo sezione |
| I poliedri | `bg-white border-2 border-blue-500` | Teoria poliedri, prismi, piramidi |
| Box interno teoria | `bg-white` | Lista elementi (facce, spigoli, vertici) |
| Box Prismi | `bg-white` + immagine PNG | Definizione prismi con immagine reale |
| Box Piramidi | `bg-white` + immagine PNG | Definizione piramidi con immagine reale |
| Esercizio 1 | `bg-orange-100` + immagini PNG | Associa oggetti a solidi con immagini reali |

**Correzioni:** ✅ FATTO
- Sostituite figure CSS con immagini PNG reali
- Esercizio 1: ridotto a 3 immagini (parallelepipedo, cubo, piramide)
- Sfondo bianco reso trasparente con ImageMagick
- Testi sotto le 4 figure dei prismi allineati con `grid grid-cols-4`

---

## p135 - GEOMETRIA (base_color: pink) ✅

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Introduzione + Solidi rotazione | `bg-white border-2 border-blue-500` | Teoria + 4 solidi di rotazione |
| Cilindro/Cono/Tronco/Sfera | nessuno (dentro introduzione) | Con immagini PNG |
| Poliedri regolari | `bg-white` no rounded | 5 solidi platonici + immagine p135_01.jpg |

**Correzioni:** ✅ FATTO
- Box cilindro, cono, tronco, sfera: rimosso bordo e sfondo, contenuti dentro box introduzione
- Usate immagini PNG:
  - Cilindro: `output-1715938802135_164_413_305_146.png`
  - Cono: `output-1715938802135_609_399_328_160.png`
  - Tronco: `output-1715938802135_169_682_313_148.png`
  - Sfera: `output-1715938802135_610_688_336_150.png`

---

## p136 - ESERCIZI (base_color: orange) ✅

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Container esercizi | `bg-orange-100` | Wrapper tutti esercizi |
| IMPARARE TUTTI (es.1) | `bg-white border-3 border-blue-500` | Classifica poliedri/non poliedri |
| Schema classificazione | `bg-gray-50` | Diagramma solidi |
| Badge "non poliedri" | `bg-pink-200` | Label rosa |
| Badge "poliedri" | `bg-purple-200` | Label viola |
| Tabella es.3 | `bg-cyan-100` header, `border-cyan-300` celle | Facce, spigoli, vertici |

**Correzioni:** ✅ FATTO
- Esercizio 2: aggiunta immagine `output-1715938802136_122_696_367_473.png`
- Tabella esercizio 3: header azzurro `bg-cyan-100`, bordi celle `border-cyan-300`
- Immagini PNG per i solidi:
  - tetraedro: `output-1715938802136_531_744_67_71.png`
  - cubo: `output-1715938802136_530_829_68_68.png`
  - piramide: `output-1715938802136_530_996_69_77.png`
  - parallelepipedo e prisma: div CSS (immagini non disponibili)

---

## p137 - GEOMETRIA (base_color: pink) ✅

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Collega solidi | nessuno sfondo | Esercizio abbinamento con immagine |
| Box Sl/St | nessuno sfondo | Definizioni inline con immagine a destra |
| Esercizio 1 | `bg-orange-100` | Colora sviluppi con immagine p137_03.jpg |

**Correzioni:** ✅ FATTO
- Rimosso bg e rounded da "Collega solidi", usata immagine `output-1715938802137_73_403_875_235.png`
- Box Sl e St: rimosso sfondo `bg-custom-blue`, testo inline, immagine `p137_02.jpg` a destra
- Esercizio 1: sostituiti sviluppi CSS con immagine `p137_03.jpg`
- Soluzioni corrette: A=parallelepipedo, B=piramide a base rettangolare, C=parallelepipedo, D=cubo

---

## p138 - GEOMETRIA (base_color: pink) ✅

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Titoli | fuori dai box | Parallelepipedo, Cubo, Prisma regolare |
| Teoria | sfondo bianco (no box) | Testo teoria |
| Box formule | `bg-pink-light w-fit` | Sl e St |

**Correzioni:** ✅ FATTO
- Box teoria rimossi, formule in pink-light, titoli fuori
- Box formule: aggiunto `w-fit`, testo `text-gray-700` (rimosso bold/blue)

---

## p139 - GEOMETRIA (base_color: pink) ✅

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Titoli Piramide/Cilindro | fuori dai box | Titoli sezione |
| Teoria | sfondo bianco (no box) | Testo teoria |
| Box formule | `bg-pink-light w-fit` | Sl e St |
| Tabella CUBI | header `bg-cyan-500`, celle `bg-cyan-50` | Azzurro |
| Tabella PARALLELEPIPEDI | header `bg-green-500`, celle `bg-green-50` | Verde |
| Tabella PRISMI | header `bg-pink-500`, celle `bg-pink-50` | Rosa |
| Tabella CILINDRI | header `bg-orange-500`, celle `bg-orange-50` | Arancione |

**Correzioni:** ✅ FATTO
- Box teoria rimossi, formule pink-light, tabelle affiancate con colori
- Box formule: aggiunto `w-fit`, testo `text-gray-700` (rimosso bold/blue)
- Rimosso `text-sm` dalle tabelle per permettere ingrandimento testi

---

## p140 - GEOMETRIA (base_color: pink) ✅

| Box | Colore Attuale | Contenuto |
|-----|----------------|-----------|
| Header MULTIPLI | `bg-blue-500` | Intestazione multipli |
| Header UNITÀ | `bg-green-500` | Intestazione unità fondamentale |
| Header SOTTOMULTIPLI | `bg-orange-500` | Intestazione sottomultipli |
| Celle tabella | `bg-white` | Valori conversione |
| Regola ×1000/÷1000 | `bg-pink-light w-fit` | Spiegazione conversione |
| Regola marca | `bg-white border` | Dove va la marca |
| Esercizio 1 tabella | celle input singole | Colori sfumati per colonna |
| Esempio esercizio 3 | allineato senza box | Inline con esercizi |

**Correzioni:** ✅ FATTO
- Regole scambiate, tabella es.1 con input singoli e colori, esempio allineato
- Regola ×1000: aggiunto `w-fit`
- Rimosso `text-sm` dalle celle tabella per permettere ingrandimento testi


---
