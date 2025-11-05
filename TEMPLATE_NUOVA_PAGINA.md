# Template per Creare Nuove Pagine

Usa questo template per chiedere a Claude di creare una nuova pagina interattiva.

---

## ISTRUZIONI PER CLAUDE

Crea una nuova pagina interattiva per il libro seguendo questi passaggi:

### 1. INFORMAZIONI LIBRO
- **Corso**: [es: Banda del BUS]
- **Volume**: [es: BUS 3]
- **Disciplina**: [es: Matematica]
- **Numero pagina**: [es: 76]
- **Titolo argomento**: [es: Frazioni - L'unità frazionaria]

### 2. IMMAGINI
Le immagini si trovano in: `~/Downloads/[nome_cartella]/`

- **Immagine di riferimento**: `[nome_file].jpg` (l'immagine completa della pagina da riprodurre)
- **Immagini scomposte**:
  - `[nome]_01.jpg` - Esercizio 1
  - `[nome]_02.jpg` - Esercizio 2
  - `[nome]_03.jpg` - Esercizio 3
  - ... (elenca tutte le immagini disponibili)

### 3. TESTO COMPLETO DELLA PAGINA

```
[Incolla qui il testo completo della pagina, inclusi:]
- Titolo principale
- Testo di ogni esercizio
- Frasi da completare
- Box informativi
- Note e spiegazioni
```

### 4. DESCRIZIONE ESERCIZI

#### Esercizio 1: [Titolo]
- **Tipo**: [es: Completa, Collega, Colora, Scegli, etc.]
- **Immagine**: `[nome_file]`
- **Input richiesti**: [descrivi i campi da completare]
- **Soluzioni**:
  - Input 1: `[soluzione corretta]`
  - Input 2: `[soluzione corretta]`

#### Esercizio 2: [Titolo]
- **Tipo**: [tipo di esercizio]
- **Immagine**: `[nome_file]`
- **Input richiesti**: [descrivi i campi]
- **Soluzioni**: [...]

#### Esercizio 3: [Titolo]
[continua per tutti gli esercizi...]

### 5. RICHIESTE SPECIALI
[Eventuali richieste particolari, es:]
- Usa colore blu per matematica
- Aggiungi badge "GIOCO" per l'esercizio 4
- Includi mascotte dei bambini (Giò, Ada, Mia)
- etc.

---

## AZIONI RICHIESTE

1. ✅ **Copiare le immagini** da Downloads a `app/assets/images/`
2. ✅ **Aggiornare il seed** (`db/seeds.rb`) aggiungendo la nuova pagina al volume corretto
3. ✅ **Creare la view** (`app/views/exercises/[slug].html.erb`) usando le immagini fornite
4. ✅ **Implementare tutti gli esercizi** con input interattivi e soluzioni
5. ✅ **Rigenerare il database** con `bin/rails db:reset`

---

## ESEMPIO COMPILATO

### 1. INFORMAZIONI LIBRO
- **Corso**: Banda del BUS
- **Volume**: BUS 3
- **Disciplina**: Matematica
- **Numero pagina**: 76
- **Titolo argomento**: Frazioni - L'unità frazionaria

### 2. IMMAGINI
Le immagini si trovano in: `~/Downloads/bus3_mat_p076/`

- **Immagine di riferimento**: `bus3_mat_p076.jpg`
- **Immagini scomposte**:
  - `p76_01.jpg` - Esercizio 1: figure geometriche
  - `p76_02.jpg` - Esercizio 2: frazioni con cerchi
  - `p76_03.jpg` - Esercizio 3: triangolo e esagono da colorare
  - `p76_04.png` - Icona cubetto
  - `p76_05.png` - Costruzione A
  - `p76_06.png` - Costruzione B
  - `p76_07.png` - Costruzione C

### 3. TESTO COMPLETO DELLA PAGINA

```
La banda del bus - Il Libro di Matematica vol.3

FRAZIONI
L'UNITÀ FRAZIONARIA

1 Osserva i disegni e completa, come nell'esempio.

• Tutte queste figure sono divise in parti ........ e solo ........ parte è colorata.

Tutte le frazioni che hanno 1 al numeratore si chiamano unità frazionarie.

2 Collega l'unità frazionaria alla sua rappresentazione.

3 Colora l'unità frazionaria e scrivila in cifre e in lettere.

4 GIOCO Osserva le tre costruzioni e indica con una X in quale costruzione
l'unità frazionaria è un quindicesimo.
```

### 4. DESCRIZIONE ESERCIZI

#### Esercizio 1: Osserva i disegni e completa
- **Tipo**: Completa (frazioni + parole)
- **Immagine**: `p76_01.jpg`
- **Input richiesti**:
  - 4 frazioni sotto le figure (1/5, 1/6, 1/8, 1/12)
  - 4 nomi in lettere
  - 2 parole nella frase ("uguali", "una")
- **Soluzioni**:
  - Stella: `1/5`, `un quinto`
  - Esagono: `1/6`, `un sesto`
  - Cerchio: `1/8`, `un ottavo`
  - Griglia: `1/12`, `un dodicesimo`
  - Frase: `uguali`, `una`

#### Esercizio 2: Collega l'unità frazionaria
- **Tipo**: Collega con dropdown
- **Immagine**: `p76_02.jpg`
- **Input richiesti**: 3 select per collegare frazioni ai cerchi
- **Soluzioni**:
  - 1/7 → primo cerchio
  - 1/10 → secondo cerchio
  - 1/5 → terzo cerchio

#### Esercizio 3: Colora l'unità frazionaria
- **Tipo**: Completa (frazione + lettere)
- **Immagine**: `p76_03.jpg`
- **Input richiesti**:
  - Triangolo: cifre e lettere
  - Esagono: cifre e lettere
- **Soluzioni**:
  - Triangolo: `1/9`, `un nono`
  - Esagono: `1/8`, `un ottavo`

#### Esercizio 4 GIOCO: Indica la costruzione
- **Tipo**: Scelta multipla (radio button)
- **Immagini**: `p76_05.png`, `p76_06.png`, `p76_07.png`
- **Input richiesti**: Seleziona quale costruzione ha 1/15
- **Soluzioni**: Costruzione C (corretta)

### 5. RICHIESTE SPECIALI
- Usa colore blu (#3B82F6) per la matematica
- Badge "GIOCO" colorato per l'esercizio 4
- Includi icona cubetto nel testo dell'esercizio 4
- Box informativo rosa con emoji 🔍 per la definizione di unità frazionaria

---

## NOTE

- **IMPORTANTE**: Usa SOLO le immagini fornite, non creare grafici SVG/CSS
- Il seed deve aggiungere la pagina in ordine numerico
- Lo slug deve seguire il pattern: `[volume]_[disciplina]_p[numero]` (es: `bus3_mat_p076`)
- La view deve seguire lo stesso pattern del file
- Tutti gli input devono avere `data-correct-answer` per la validazione automatica
