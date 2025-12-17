# Correzioni Box P250-P263

## Correzioni applicate

### Bug corretto (commit ea3fb65)
- `bg-custom-blue-light-light` → `bg-custom-blue-light` (doppio -light rimosso)
- Correzione applicata globalmente a 105 file

---

## p250 - PROBLEMI DI GEOMETRIA (base_color: cyan) - CORRETTO

### Box utilizzati:
- **Introduzione** - testo semplice con link pink a p251
- **11 problemi** senza border, con input per risposte

### Elementi:
- Partial `shared/frazione` per problema 6
- Grid 2 colonne con `divide-x divide-custom-blue-light`
- Colonna 1: problemi 1-6 | Colonna 2: problemi 7-11

### Immagini utilizzate:
- Es. 4: `output-1715938802250_375_377_163_182.png` (a destra del testo)
- Es. 10: `output-1715938802250_616_738_295_99.png` (sotto il testo)
- Es. 11: `p250_02.jpg` (pianta casa, sotto il box suggerimento)

### Correzioni applicate:
- [x] Rimosso box azzurro introduzione
- [x] "vedi p. seguente" trasformato in link pink
- [x] Rimossi border dai problemi
- [x] Colonne corrette: 1-6 | 7-11 con divider
- [x] Es. 4: immagine pentagono a destra
- [x] Es. 10: immagine pista sotto
- [x] Es. 11: box suggerimento dotted a destra + immagine pianta sotto
- [x] Input allineati a destra negli esercizi con immagini

### Correzioni da fare:
- [x] Esercizio 6: input su 3 righe (h, Pomodori, Zucche)
- [x] Esercizio 7: input su 2 righe (Area tappeto, Pavimento libero)
- [x] Esercizio 9: input su 2 righe (r, d)
- [x] Esercizio 4: immagine sotto centrata in mobile (flex-col md:flex-row, mx-auto md:mx-0)
- [x] Esercizio 11: box Suddividi con border base_color, w-1/3, h-fit shrink-0, data-text-toggle-ignore

---

## p251 - FORMULE FIGURE PIANE (base_color: cyan)

### Box utilizzati:
- **Box formule** (`bg-custom-blue-light rounded-2xl`) - contiene 8 card formule
  - Card interne: `bg-white rounded border border-cyan-300`
  - Figure: Quadrato, Rettangolo, Parallelogramma, Trapezio, Rombo, Triangolo, Poligoni regolari, Cerchio
- **Tabella Quadrato/Cerchio** - header `bg-custom-blue-light`
- **Tabella Pentagono/Esagono** - header `bg-custom-blue-light`

### Esercizi:
1. Completa le tabelle
2. Risolvi sul quaderno (4 problemi testuali)


### Correzioni applicate:
- [x] Box formule: layout responsivo `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4`
- [x] Tabelle Quadrato/Cerchio separate in 2 tabelle distinte con `lg:grid-cols-2`
- [x] Tabelle Pentagono/Esagono separate in 2 tabelle distinte
- [x] Sottotitoli tabelle (Lato, Perimetro, Area, ecc.) con `bg-white`
- [x] Input con solo numeri, unita di misura nella cella
- [x] Esercizio 2: 2 colonne con divider `divide-<%= @pagina.base_color %>-300`
- [x] Colonna 1: a. e b. | Colonna 2: c. e d.
- [x] Risultati allineati a destra con input per P e A

---

## p252 - POLIEDRI E SOLIDI DI ROTAZIONE (base_color: cyan)

### Box utilizzati:
- **Box teoria** (`bg-custom-blue-light rounded-2xl`) - grid 2 colonne: Poliedri e Solidi di rotazione
- **IMPARARE TUTTI** (`bg-white rounded-2xl border-3 border-yellow-400`) - Es. 1
- **Tabella poliedri** - header `bg-custom-blue-light`

### Immagini:
- `p252_01.jpg` - Poliedri
- `p252_02.jpg` - Solidi di rotazione
- `output-1715938802252_129_523_469_416.png` - Solidi esercizio

### Esercizi:
1. IMPARARE TUTTI - Cerchia poliedri/solidi rotazione + tabella nomi
2. Completa tabella facce/vertici/spigoli

### Correzioni applicate:
- [x] Box teoria: immagini centrate e allineate in basso con `flex flex-col items-center` e `mt-auto`
- [x] IMPARARE TUTTI: tabella a destra dell'immagine con `flex flex-col md:flex-row`, input lunghi come colonna, Cubo e Sfera in cyan
- [x] Esercizio 2: testo a sinistra (md:w-1/3), tabella a destra (md:flex-1), formula su 3 righe con `text-cyan-600 font-bold`

---

## p253 - SUPERFICIE CUBO E PARALLELEPIPEDO (base_color: cyan)

### Box utilizzati:
- **Box teoria** (`bg-custom-blue-light rounded-2xl`) - grid 2 colonne: Cubo e Parallelepipedo con formule Sl e St
- **IMPARARE TUTTI** (`bg-white rounded-2xl border-3 border-yellow-400`) - Es. 1
- **Tabella Cubo** - header `bg-custom-blue-light`
- **Tabella Parallelepipedo** - header `bg-custom-blue-light`

### Immagini:
- `p253_01.jpg` - Cubo
- `p253_02.jpg` - Parallelepipedo
- `output-1715938802253_150_579_806_158.png` - Sviluppi solidi

### Esercizi:
1. IMPARARE TUTTI - Colora sviluppi solidi
2. Completa tabelle Cubo e Parallelepipedo

### Correzioni applicate:
- [x] Box teoria: aggiunto `md:divide-x-2 divide-cyan-300`, margine `mt-6 md:mt-0 md:pl-6` per colonna Parallelepipedo
- [x] Box teoria: immagini 20% più larghe (`max-w-sm` invece di `max-w-xs`)
- [x] Tabelle: rimosso `w-full`, sottotitoli con `bg-white font-normal`
- [x] Tabelle: input con `w-20` invece di `flex-1`, unità nella cella
- [x] Tabella Parallelepipedo: header su 2 righe (Dimensioni<br>base, Perimetro<br>di base, Area<br>di base)
- [x] Risposte allineate a destra

---

## p254 - SUPERFICIE PRISMA E PIRAMIDE (base_color: cyan)

### Box utilizzati:
- **Box teoria** (`bg-custom-blue-light rounded-2xl`) - grid 2 colonne: Prisma regolare e Piramide
- **IMPARARE TUTTI** (`bg-white rounded-2xl border-3 border-yellow-400`) - Es. 1

### Immagini:
- `p254_01.jpg` - Prisma regolare
- `p254_02.jpg` - Piramide
- `p254_03.jpg` - `p254_06.jpg` - Solidi esercizio 2
- `output-...` - Immagini solidi Es. 1

### Esercizi:
1. IMPARARE TUTTI - Quale poligono hanno per base?
2. Calcola superficie laterale e totale (4 solidi)

### Correzioni applicate:
- [x] Box teoria: aggiunto `md:divide-x-2 divide-cyan-300` e margine per seconda colonna
- [x] Box teoria: immagini 20% più larghe (`max-w-sm` invece di `max-w-xs`)
- [x] IMPARARE TUTTI: ottagono e 8 in `font-bold text-cyan-600`
- [x] Esercizio 2: rimossi borders, layout `grid-cols-1 md:grid-cols-2 xl:grid-cols-4`
- [x] Esercizio 2: divider solo a 4 colonne (`xl:divide-x-2` invece di `md:divide-x-2`)
- [x] Input con solo numeri, unità nelle celle, risposte allineate a destra

---

## p255 - SUPERFICIE CILINDRO (base_color: cyan)

### Box utilizzati:
- **Box teoria** (`bg-custom-blue-light rounded-2xl`) - Cilindro con formule

### Immagini:
- `p255_01.jpg` - Cilindro teoria
- `p255_02.jpg` - `p255_06.jpg` - Cilindri esercizi
- `output-1715938802255_151_522_577_323.png` - Sviluppo cilindro

### Esercizi:
1. Disegna lo sviluppo
2. Calcola superficie totale (4 cilindri)

### Correzioni applicate:
- [x] Box teoria: aggiunto `w-fit mx-auto` per centrarlo
- [x] Box teoria: immagine raddoppiata (`max-w-[300px]` invece di `max-w-[150px]`)
- [x] Esercizio 2: layout 4 colonne, divider solo a xl (`xl:divide-x-2`)
- [x] Input con solo numeri

---

## p256 - MISURE DI VOLUME (base_color: cyan)

### Box utilizzati:
- **Tabella misure volume** - grande tabella con multipli/sottomultipli
  - Header MULTIPLI/UNITA/SOTTOMULTIPLI: `bg-custom-blue-light`
  - Unità fondamentale: `bg-cyan-200`
- **IMPARARE TUTTI** (`bg-white rounded-2xl border-3 border-yellow-400`) - Es. 1

### Immagini:
- `p256_01.jpg` - `p256_04.jpg` - Solidi cubetti

### Esercizi:
1. IMPARARE TUTTI - Completa equivalenze volume
2. Conta cubetti solidi (4 figure)

### Correzioni applicate:
- [x] Esercizio 2: rimossi borders, layout `grid-cols-1 md:grid-cols-2 xl:grid-cols-4`
- [x] Esercizio 2: divider solo a 4 colonne (`xl:divide-x-2`)

---

## p257 - VOLUME PARALLELEPIPEDO E CUBO (base_color: cyan)

### Box utilizzati:
- **Box teoria** (`bg-custom-blue-light rounded-2xl`) - grid 2 colonne: Volume parallelepipedo e cubo
- **Tabella volume solidi** - header `bg-custom-blue-light`, esempio `bg-custom-blue-light`

### Immagini:
- `p257_01.jpg` - Parallelepipedo
- `p257_02.jpg` - Cubo
- `p257_03.jpg`, `p257_04.jpg` - Solidi esercizio 1
- `output-...` - Figure tabella

### Esercizi:
1. Calcola volume due solidi
2. Completa tabella (spigolo, volume cubo, numero cubi, volume solido)

### Correzioni applicate:
- [x] Box teoria: `w-fit mx-auto`, `px-4` ai div interni
- [x] Box teoria: formule a destra immagini con `flex flex-col md:flex-row items-center gap-4`
- [x] Box teoria: aggiunto `md:divide-x-2 divide-cyan-300`
- [x] Esercizio 1: rimosso divider, aggiunto bordo `border-2 border-base_color-300 rounded-lg p-2 w-fit mx-auto` ai div V=
- [x] Esercizio 1: separati units dagli input
- [x] Tabella Esercizio 2: rimosso `w-full`, aggiunto `mx-auto`
- [x] Tabella Esercizio 2: cella header Figura vuota e senza bordi
- [x] Tabella Esercizio 2: immagini `max-w-[80px]`, header su 2 righe
- [x] Tabella Esercizio 2: riga esempio sfondo bianco, testo `text-cyan-600`
- [x] Tabella Esercizio 2: input con solo numeri, units nelle celle allineate a destra

---

## p258 - DIAGRAMMI DI EULERO-VENN (base_color: cyan)

### Box utilizzati:
- **IMPARARE TUTTI** (`bg-white rounded-2xl border-3 border-yellow-400`) - Es. 1
- **Tabella bambini/cibo** - header `bg-custom-blue-light`

### Immagini:
- `p258_01.jpg` - Diagramma Eulero-Venn solidi
- `p258_02.jpg` - Diagramma Eulero-Venn bambini

### Esercizi:
1. IMPARARE TUTTI - Inserisci nomi solidi nel diagramma
2. Completa diagramma con iniziali bambini

### Note:
- Pagina OK, nessuna correzione necessaria

---

## p259 - ISTOGRAMMA E IDEOGRAMMA (base_color: cyan)

### Box utilizzati:
- **IMPARARE TUTTI** (`bg-white rounded-2xl border-3 border-yellow-400`) - Es. 1
- **Tabella dati pioggia** - header `bg-custom-blue-light`
- **Tabella ideogramma** - header `bg-custom-blue-light`

### Immagini:
- `p259_01.jpg` - Istogramma lingue straniere
- `p259_02.jpg` - Tabella temperature e diagramma cartesiano
- `output-...` - Simbolo pioggia, pioggia Torino

### Esercizi:
1. IMPARARE TUTTI - Rispondi domande istogramma
2. Rappresenta ideogramma pioggia
3. Rappresenta diagramma cartesiano temperature

### Note:
- Pagina OK, nessuna correzione necessaria

---

## p260 - FREQUENZE E PERCENTUALI (base_color: cyan)

### Box utilizzati:
- **Tabella frequenza materie** - header `bg-custom-blue-light`
- **Box areogramma** (`bg-custom-blue-light rounded-2xl`) - legenda colori + areogramma quadrato
- **Tabella film** - header `bg-custom-blue-light`

### Immagini:
- `output-1715938802260_727_492_238_237.png` - Areogramma quadrato
- `p260_02.jpg` - Areogramma circolare film

### Esercizi:
1. Trasforma frequenze in percentuali + areogramma quadrato
2. Inserisci percentuali areogramma + calcola numero ragazzi

### Note:
- Pagina OK, nessuna correzione necessaria

---

## p261 - MEDIA, MODA, MEDIANA (base_color: cyan)

### Box utilizzati:
- **Tabella Anno 2024** - header `bg-custom-blue-light`
- **Tabella ordinamento** - casella centrale `bg-yellow-200`
- **Tabella Anno 1950** - header `bg-custom-blue-light`
- **Tabella confronto** - header `bg-custom-blue-light`

### Esercizi:
1. Calcola media, mediana, moda per 2024 e 1950
2. Confronta dati in tabella

### Note:
- Radio button per selezione Media/Moda/Mediana
- Nessun box IMPARARE TUTTI
- Pagina OK, nessuna correzione necessaria

---

## p262 - PROBABILITA (base_color: cyan)

### Box utilizzati:
- **IMPARARE TUTTI** (`bg-white rounded-2xl border-3 border-yellow-400`) - Es. 1
- **Tabella Ruota della Gallina** - header `bg-custom-blue-light`, esempio `bg-custom-blue-light`

### Immagini:
- `p262_01.jpg` - Ruota della Gallina

### Partial:
- `shared/frazione` con `num_answer` per input

### Esercizi:
1. IMPARARE TUTTI - Completa tabella probabilita
2. Calcola probabilita carte (frazione e percentuale)
3. Vero/Falso lancio dado

### Note:
- Pagina OK, nessuna correzione necessaria

---

## p263 - STATISTICA E PROBABILITA (base_color: cyan)

### Box utilizzati:
- **IMPARARE TUTTI** (`bg-white rounded-2xl border-3 border-yellow-400`) - Es. 1
- **Tabella sport** - header `bg-custom-blue-light`
- **Tabella canestri** - header `bg-custom-blue-light`

### Immagini:
- `output-1715938802263_611_341_302_303.png` - Areogramma quadrato

### Partial:
- `shared/frazione` con `num_answer` per input

### Esercizi:
1. IMPARARE TUTTI - Rappresenta sport in areogramma
2. Calcola moda, media, mediana canestri
3. Calcola probabilita palline (frazione e percentuale)

### Note:
- Pagina OK, nessuna correzione necessaria

---

## Riepilogo Box

| Pagina | bg-custom-blue-light | IMPARARE TUTTI | Tabelle | Immagini |
|--------|:--------------------:|:--------------:|:-------:|:--------:|
| p250   | 1                    | -              | -       | -        |
| p251   | 20                   | -              | 2       | -        |
| p252   | 7                    | 1              | 2       | 3        |
| p253   | 13                   | 1              | 2       | 3        |
| p254   | 1                    | 1              | -       | 9        |
| p255   | 1                    | -              | -       | 6        |
| p256   | 13                   | 1              | 1       | 4        |
| p257   | 11                   | -              | 1       | 8        |
| p258   | 4                    | 1              | 1       | 2        |
| p259   | 4                    | 1              | 2       | 4        |
| p260   | 4                    | -              | 2       | 2        |
| p261   | 10                   | -              | 4       | -        |
| p262   | 11                   | 1              | 1       | 1        |
| p263   | 9                    | 1              | 2       | 1        |

---

## Note generali

- Tutte le pagine sono del **Quaderno Esercizi** (stile cyan)
- **p264 non esiste** (conteneva solo crediti nel libro originale)
- Pattern tabelle: header `bg-custom-blue-light`, celle `bg-white`, bordi `border-cyan-400`
- Pattern IMPARARE TUTTI: `bg-white rounded-2xl border-3 border-yellow-400`
- Pattern box teoria: `bg-custom-blue-light rounded-2xl`
- Testo evidenziato: `text-cyan-600`
- Bullet: `text-cyan-500`
