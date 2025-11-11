# Prompt per Creare Pagine da File HTML/PNG Esistenti

## FORMATO SEMPLICE

```
Crea la pagina [numero] usando i file HTML e PNG che si trovano in:
- HTML: /home/paolotax/Windows/book_844/epub/html/
- PNG: /home/paolotax/Windows/book_844/pages/
- Immagini: /home/paolotax/Windows/book_844/epub/images/

Usa il PNG per vedere la grafica degli esercizi.
```

---

## ESEMPIO COMPLETO - Pagina 110

```
Crea pagina 110 usando i file:
- /home/paolotax/Windows/book_844/epub/html/1715676002110.html
- /home/paolotax/Windows/book_844/pages/1715676002110.png
- /home/paolotax/Windows/book_844/epub/images/p110_01.jpg
```

### Quello che farò automaticamente:

1. **📖 Analisi dei file sorgente:**
   - Leggo il file HTML per estrarre il contenuto testuale
   - Visualizzo il PNG per capire la struttura grafica e gli esercizi
   - Identifico le immagini correlate nella cartella images

2. **🎨 Creazione della struttura ERB:**
   - Wrapper principale con `data-controller="exercise-checker"` per controllo globale
   - Header con badge colorato (SINTASSI, MORFOLOGIA, etc.) e numero pagina
   - Box teoria con eventuali illustrazioni
   - Esercizi interattivi con i controller Stimulus appropriati

3. **🔧 Implementazione esercizi interattivi:**

   **Per esercizi "Sottolinea":**
   ```erb
   <div data-controller="word-highlighter">
     <span data-word-highlighter-target="word"
           data-correct="true"
           data-action="click->word-highlighter#toggleHighlight">
       parola da sottolineare
     </span>
   </div>
   ```

   **Per esercizi "Completa" con risposte specifiche:**
   ```erb
   <div data-controller="fill-blanks">
     <input type="text"
            data-fill-blanks-target="input"
            data-correct-answer="risposta corretta">
   </div>
   ```

   **Per esercizi "Completa" con risposte libere:**
   ```erb
   <input type="text"
          data-fill-blanks-target="input"
          data-correct-answer="libera">
   ```

   **Per esercizi "Scegli" (radio/checkbox):**
   ```erb
   <input type="radio" name="question1" data-correct-answer="true">
   <input type="checkbox" data-correct-answer="false">
   ```

4. **🎮 Sistema di controllo unificato:**
   - Nessun pulsante di verifica nei singoli esercizi
   - Uso di `<%= render 'shared/exercise_controls', color: 'orange' %>` in fondo
   - I pulsanti globali gestiscono: Controlla, Soluzioni, Ricomincia, Navigazione

5. **💾 Configurazione finale:**
   - Copio immagini in `app/assets/images/` con naming convention
   - Aggiorno il seed in `db/seeds.rb`
   - Rigenero il database con `rails db:seed`

---

## PERCORSO COMPLETO PER NUOVA PAGINA

### 1. IDENTIFICAZIONE FILE
```bash
# Trova i file HTML per la pagina desiderata
ls /home/paolotax/Windows/book_844/epub/html/*[numero]*.html

# Trova il PNG della pagina
ls /home/paolotax/Windows/book_844/pages/*[numero]*.png

# Trova immagini correlate
ls /home/paolotax/Windows/book_844/epub/images/p[numero]*
```

### 2. ANALISI CONTENUTO
- Leggere HTML per testo e struttura
- Visualizzare PNG per capire layout e tipologie esercizi
- Identificare elementi interattivi necessari

### 3. CREAZIONE VIEW ERB
Struttura standard:
```erb
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8" data-controller="exercise-checker">

  <!-- Header con badge e numero pagina -->

  <!-- Teoria/Introduzione -->

  <!-- Esercizi con controller appropriati -->

  <!-- Exercise controls -->
  <%= render 'shared/exercise_controls', color: 'colore_appropriato' %>
</div>
```

### 4. AGGIORNAMENTO SEED
```ruby
{ numero: [num], titolo: "[titolo]", slug: "nvl5_gram_p[num]", view_template: "nvl5_gram_p[num]" }
```

### 5. DEPLOY
```bash
rails db:seed
```

---

## TIPOLOGIE ESERCIZI RICONOSCIUTI

| Tipo | Descrizione | Controller | Attributi |
|------|-------------|------------|-----------|
| **Sottolinea** | Click su parole | `word-highlighter` | `data-correct="true"` |
| **Cerchia** | Checkbox multipli | `exercise-checker` | `data-correct-answer="true/false"` |
| **Completa** | Input testo | `fill-blanks` | `data-correct-answer="risposta"` |
| **Collega** | Dropdown select | `exercise-checker` | `data-correct-answer="valore"` |
| **Scegli** | Radio button | `exercise-checker` | `data-correct-answer="true"` |
| **Colora** | Click su aree | `word-highlighter` | Multi-color mode |
| **Vero/Falso** | Radio binari | `exercise-checker` | `data-correct-answer="true/false"` |

---

## NOTE IMPORTANTI

### ⚠️ Da Ricordare:
- **NO placeholder con puntini** (`......`) negli input
- **NO pulsanti verifica individuali** per esercizio
- **SI controllo globale** con `exercise-checker` wrapper
- **SI exercise_controls** per tutti i controlli

### 🎨 Colori per Badge:
- **SINTASSI**: giallo/arancione
- **MORFOLOGIA**: blu/azzurro
- **LESSICO**: verde
- **ORTOGRAFIA**: rosso/rosa
- **VERIFICA**: viola

### 📝 Convenzioni Naming:
- File ERB: `nvl5_gram_p[numero].html.erb`
- Immagini: `nvl5_gram_p[numero]_[nn].jpg`
- Slug/Route: `nvl5_gram_p[numero]`

---

## ESEMPIO PROMPT MINIMO

```
Crea pagina 111 dai file in /home/paolotax/Windows/book_844/
Usa HTML e PNG per struttura, exercise-checker globale, no pulsanti individuali.
```

## ESEMPIO PROMPT DETTAGLIATO

```
Crea pagina 111:
- HTML: /home/paolotax/Windows/book_844/epub/html/1715676002111.html
- PNG: /home/paolotax/Windows/book_844/pages/1715676002111.png
- Immagini: /home/paolotax/Windows/book_844/epub/images/p111*.jpg

Implementa:
1. Esercizio 1: sottolinea con word-highlighter
2. Esercizio 2: completa con fill-blanks (risposte specifiche)
3. Esercizio 3: cerchia con checkbox

Usa exercise-checker globale, no pulsanti individuali.
Aggiungi al seed e rigenera database.
```

---

## CHECKLIST FINALE

- [ ] File HTML letto per contenuto testuale
- [ ] PNG visualizzato per struttura grafica
- [ ] Immagini copiate in assets con naming corretto
- [ ] View ERB creata con `data-controller="exercise-checker"`
- [ ] Esercizi implementati con controller appropriati
- [ ] Nessun pulsante verifica individuale
- [ ] `exercise_controls` aggiunto in fondo
- [ ] Seed aggiornato con nuovo record
- [ ] Database rigenerato con `rails db:seed`
- [ ] Pagina accessibile tramite `/pagine/nvl5_gram_p[numero]`