# Prompt per Creare Pagine da File HTML/PNG Esistenti

## 🚀 IMPORT AUTOMATICO (CONSIGLIATO)

**Prima di creare pagine, importa il libro con il rake task:**

```bash
# Importa libro completo (crea struttura organizzata)
rake images:import[book_844,nvl5_gram]

# Per test senza copiare
rake images:import[book_844,nvl5_gram,dry_run]
```

Questo crea automaticamente la struttura:
```
app/assets/images/nvl5_gram/
  ├── p001/
  │   ├── page.png              # PNG della pagina
  │   ├── 1702926004001.html    # HTML originale
  │   └── (eventuali immagini)
  ├── p056/
  │   ├── page.png
  │   ├── 1702926004056.html
  │   ├── 1715676002056.html    # Versioni multiple
  │   └── p056_01.jpg
  └── p192/...
```

---

## FORMATO SEMPLICE (File già Importati)

```
Crea la pagina 56 usando i file in:
app/assets/images/nvl5_gram/p056/

Usa page.png per vedere la grafica degli esercizi.
```

**Oppure (metodo vecchio, sconsigliato):**

```
Crea la pagina [numero] usando i file HTML e PNG che si trovano in:
- HTML: /home/paolotax/Windows/book_844/epub/html/
- PNG: /home/paolotax/Windows/book_844/pages/
- Immagini: /home/paolotax/Windows/book_844/epub/images/
```

---

## ⚡ FLUSSO CONSIGLIATO PER CREARE MULTIPLE PAGINE

Quando devi creare MULTIPLE pagine (es: da 119 a 125), segui questo flusso ottimizzato:

### 1. LETTURA FILE SORGENTE
```bash
# Leggi TUTTI i file PNG e HTML delle pagine da creare
- /home/paolotax/Windows/book_844/pages/1715676002119.png
- /home/paolotax/Windows/book_844/epub/html/1715676002119.html
- /home/paolotax/Windows/book_844/pages/1715676002120.png
- /home/paolotax/Windows/book_844/epub/html/1715676002120.html
# ... e così via per tutte le pagine
```

### 2. AGGIORNA SEED.RB SUBITO
```ruby
# Aggiungi TUTTE le nuove pagine al file db/seeds.rb
{ numero: 119, titolo: "ANALISI LOGICA - Esercizi", slug: "nvl5_gram_p119", view_template: "nvl5_gram_p119" },
{ numero: 120, titolo: "La grammatica valenziale", slug: "nvl5_gram_p120", view_template: "nvl5_gram_p120" },
# ... tutte le altre pagine
```

### 3. ESEGUI IL SEED
```bash
# Esegui rails db:seed PRIMA di creare i file ERB
rails db:seed
```

### 4. CREA I FILE ERB
```bash
# Ora crea i file ERB uno alla volta
# Le pagine sono già nel database, quindi puoi testarle subito
app/views/exercises/nvl5_gram_p119.html.erb
app/views/exercises/nvl5_gram_p120.html.erb
# ...
```

### 5. CONTROLLA OGNI ESERCIZIO
**⚠️ IMPORTANTE: Dopo aver creato ogni pagina, verifica esercizio per esercizio:**

```
Per ogni esercizio nella pagina:
1. ✅ C'è il wrapper `data-controller="exercise-checker"` sul div principale della pagina?
2. ✅ L'esercizio ha il controller Stimulus appropriato?
   - Sottolinea/Cerchia → `word-highlighter`
   - Completa → `fill-blanks`
   - Dividi in sintagmi → `syntagm-divider`
   - Scelta multipla → `multiple-choice`
3. ✅ Gli attributi `data-*` sono corretti per il tipo di esercizio?
4. ✅ I bottoni `exercise_controls` sono alla FINE della pagina, DENTRO il wrapper?
5. ✅ Se word-highlighter monocromatico → c'è il hidden color selector?
6. ✅ Se word-highlighter TIPO 2 (frasi principali/secondarie) → TUTTE le frasi sono cliccabili con data-correct="true/false"?
```

**Esempio di verifica:**
```erb
<!-- ✅ CORRETTO -->
<div data-controller="exercise-checker">

  <!-- Esercizio 1: word-highlighter -->
  <div data-controller="word-highlighter">
    <!-- Hidden color selector per monocolor -->
    <div class="hidden">
      <span data-word-highlighter-target="colorBox" data-color="yellow"></span>
    </div>
    <span data-word-highlighter-target="word" data-correct="yellow">parola</span>
  </div>

  <!-- Esercizio 2: fill-blanks -->
  <div data-controller="fill-blanks">
    <input data-fill-blanks-target="input" data-correct-answer="risposta">
  </div>

  <!-- Bottoni DENTRO il wrapper -->
  <%= render 'shared/exercise_controls', color: 'cyan' %>
</div>
```

### ✅ VANTAGGI DI QUESTO FLUSSO:
- ✅ Le pagine sono già nel database, quindi puoi testarle subito dopo la creazione
- ✅ Eviti di dover ricordare di aggiornare seeds.rb alla fine
- ✅ Puoi verificare che non ci siano errori nel seed prima di investire tempo nella creazione
- ✅ Il seed gira una volta sola (più efficiente)
- ✅ Puoi vedere subito le pagine nell'interfaccia mentre le crei

### ❌ DA EVITARE:
- ❌ Creare tutti i file ERB e poi aggiornare seeds.rb alla fine
- ❌ Eseguire db:seed multiple volte (una per ogni pagina)
- ❌ Dimenticarsi di aggiornare seeds.rb

---

## ESEMPIO COMPLETO - Pagina 110

**Metodo consigliato (file già importati):**
```
Crea pagina 110 usando i file in:
app/assets/images/nvl5_gram/p110/
```

**Metodo alternativo (percorsi diretti):**
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

### 0. IMPORT LIBRO (se non già fatto)
```bash
# Import completo con rake task
rake images:import[book_844,nvl5_gram]
```

### 1. IDENTIFICAZIONE FILE

**Metodo consigliato (file già organizzati):**
```bash
# Lista tutti i file della pagina
ls app/assets/images/nvl5_gram/p110/

# Output tipico:
# page.png
# 1702926004110.html
# 1715676002110.html
# p110_01.jpg
```

**Metodo alternativo (file originali):**
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

### 5. GESTIONE IMMAGINI E FILE

**IMPORTANTE: Nuovo Sistema di Organizzazione File**

A partire dal 13 novembre 2024, tutti i file (HTML, PNG, immagini) devono essere copiati in una cartella dedicata all'interno di `app/assets/images/`:

```bash
# Crea la cartella per la pagina
mkdir -p app/assets/images/nvi5_mat/p0XX/

# Copia TUTTI i file della pagina nella cartella dedicata
cp ~/Windows/book_882/1715676002XXX.html app/assets/images/nvi5_mat/p0XX/
cp ~/Windows/book_882/pages/1715676002XXX.png app/assets/images/nvi5_mat/p0XX/page.png
cp ~/Windows/book_882/epub/images/p0XX*.jpg app/assets/images/nvi5_mat/p0XX/
```

**Struttura Cartelle:**
```
app/assets/images/
├── nvi5_mat/
│   ├── p046/
│   │   ├── page.png          # PNG pagina originale (per click-to-view)
│   │   ├── p046_01.jpg       # Immagini della pagina
│   │   └── p046_02.jpg
│   ├── p047/
│   │   ├── page.png
│   │   └── p047_01.jpg
│   └── p051/
│       ├── page.png
│       ├── p051_01.jpg       # Esempio espressioni senza parentesi
│       └── p051_02.jpg       # Esempio espressioni con parentesi
└── nvl5_gram/
    ├── p110/
    │   ├── page.png
    │   └── p110_01.jpg
    └── p111/
        └── page.png
```

**Riferimenti nelle View ERB:**
```erb
<!-- PNG per click-to-view -->
<div data-controller="exercise-checker page-viewer"
     data-page-viewer-image-url-value="<%= asset_path('nvi5_mat/p051/page.png') %>">

  <!-- Numero pagina cliccabile -->
  <div data-action="click->page-viewer#openOriginal">51</div>

  <!-- Immagini della pagina -->
  <%= image_tag "nvi5_mat/p051/p051_01.jpg", class: "..." %>
</div>
```

**Vantaggi:**
- ✅ Tutti i file della pagina sono organizzati insieme
- ✅ Facile trovare e gestire le risorse per ogni pagina
- ✅ Niente conflitti di naming tra pagine diverse
- ✅ Sistema di backup più semplice (cartella per cartella)
- ✅ Click sul numero pagina apre il PNG originale

**VECCHIO Sistema (deprecato):**
```bash
# ❌ NON fare più così
cp ~/Windows/book_882/epub/images/p051_01.jpg app/assets/images/
cp ~/Windows/book_882/epub/images/p051_02.jpg app/assets/images/
```

### 6. DEPLOY
```bash
rails db:seed
```

---

## CONTROLLER STIMULUS DISPONIBILI

### 1. **exercise-checker** (Controller Principale)
**Uso**: Wrapper principale per tutta la pagina, gestisce verifica globale di tutti gli esercizi

```erb
<div class="max-w-6xl mx-auto p-3 md:p-8 bg-gradient-to-br from-lime-50 via-white to-green-50 rounded-3xl shadow-xl"
     data-controller="exercise-checker">

  <!-- Tutti gli esercizi della pagina -->

  <%= render 'shared/exercise_controls', color: 'green' %>
</div>
```

**Quando usarlo**: SEMPRE come wrapper principale di ogni pagina

---

### 2. **fill-blanks** (Completamento Testi)
**Uso**: Per esercizi "Completa", "Scrivi", input di testo

```erb
<div data-controller="fill-blanks">
  <p class="text-lg">
    La capitale d'Italia è
    <input type="text"
           class="border-b-2 border-blue-400 px-2 py-1 text-center w-32"
           data-fill-blanks-target="input"
           data-correct-answer="Roma">
  </p>
</div>
```

**Attributi importanti**:
- `data-fill-blanks-target="input"`: identifica l'input
- `data-correct-answer="risposta"`: risposta corretta
- `data-correct-answer="libera"`: per risposte libere (non controllate)

**Quando usarlo**:
- ✅ Completa le frasi
- ✅ Completa la tabella
- ✅ Scrivi la risposta
- ✅ Calcola il risultato

---

### 3. **word-highlighter** (Sottolinea/Cerchia/Evidenzia)
**Uso**: Per esercizi "Sottolinea", "Cerchia", "Colora" parole/elementi

**⚠️ REGOLE IMPORTANTI:**
- **Nel titolo**: metti il quadratino colorato INLINE con la parola (es: "attributo⬜")
- **Nel titolo**: NON usare `flex items-center flex-wrap gap-2`, metti tutto in linea con `mr-2` per spacing
- **Nel container**: aggiungi `cursor-pointer` al div che contiene gli esercizi
- **Sulle parole**: NON mettere `cursor-pointer`, `hover:bg-*`, o `transition` sugli span individuali
- **Sulle parole**: usa solo `class="px-1 rounded"` per lo styling base

**Modalità monocromatica - TIPO 1: Sottolinea solo le parole corrette** (un solo colore):
```erb
<div data-controller="word-highlighter" data-word-highlighter-multi-color-value="false">
  <h2 class="text-lg md:text-xl font-bold text-gray-700 mb-4">
    <span class="bg-blue-500 text-white rounded-full w-8 h-8 md:w-10 md:h-10 inline-flex items-center justify-center mr-2">1</span>
    <span class="bg-blue-500 text-white px-4 py-2 rounded-lg font-bold mr-2">IMPARARE TUTTI</span>
    Sottolinea le <strong class="underline">apposizioni<span class="inline-block w-6 h-6 bg-yellow-300 rounded ml-1 align-middle cursor-pointer transition transform hover:scale-110" data-word-highlighter-target="colorBox" data-color="yellow" data-action="click->word-highlighter#selectColor"></span></strong>.
  </h2>

  <!-- Hidden color selector for monocolor mode - OBBLIGATORIO! -->
  <div class="hidden">
    <div class="w-6 h-6 bg-yellow-300"
         data-word-highlighter-target="colorBox"
         data-color="yellow">
    </div>
  </div>

  <div class="space-y-4 cursor-pointer">
    <div class="bg-white p-4 rounded-lg">
      Il <span data-word-highlighter-target="word"
               data-correct="yellow"
               data-action="click->word-highlighter#toggleHighlight"
               class="px-1 rounded">dottor</span> Verdi ha visitato mio fratello.
    </div>
  </div>
</div>
```

**Modalità monocromatica - TIPO 2: Frasi principali/secondarie con TUTTE le parole cliccabili** (validazione true/false):

⚠️ **IMPORTANTE**: In questo tipo di esercizio, lo studente deve poter cliccare QUALSIASI parte della frase per sottolinearla. Il sistema poi verifica se ha sottolineato le parti corrette o sbagliate.

```erb
<div data-controller="word-highlighter" data-word-highlighter-multi-color-value="false">
  <h2 class="text-lg md:text-xl font-bold text-gray-700 mb-4">
    <span class="bg-purple-500 text-white rounded-full w-8 h-8 md:w-10 md:h-10 inline-flex items-center justify-center mr-2">1</span>
    <span class="bg-purple-500 text-white px-4 py-2 rounded-lg font-bold mr-2">IMPARARE TUTTI</span>
    In ogni periodo colora solo la <strong class="underline">frase principale<span class="inline-block w-6 h-6 bg-red-300 rounded ml-1 align-middle cursor-pointer transition transform hover:scale-110" data-word-highlighter-target="colorBox" data-color="red" data-action="click->word-highlighter#selectColor"></span></strong>.
  </h2>

  <!-- Hidden color selector for monocolor mode - OBBLIGATORIO! -->
  <div class="hidden">
    <span data-word-highlighter-target="colorBox" data-color="red"></span>
  </div>

  <div class="space-y-4 cursor-pointer">
    <div class="bg-white border-2 border-purple-200 rounded-xl p-4">
      <!-- TUTTE le frasi (principali E secondarie) DEVONO essere cliccabili -->
      <span data-word-highlighter-target="word"
            data-correct="true"
            data-action="click->word-highlighter#toggleHighlight"
            class="px-1 rounded">Antonella aveva fretta di tornare a casa</span>
      <span data-word-highlighter-target="word"
            data-correct="false"
            data-action="click->word-highlighter#toggleHighlight"
            class="px-1 rounded">perché la mamma la stava aspettando.</span>
    </div>
  </div>
</div>
```

**Differenze tra TIPO 1 e TIPO 2:**

| Aspetto | TIPO 1 (Sottolinea parole) | TIPO 2 (Frasi principali/secondarie) |
|---------|----------------------------|--------------------------------------|
| **data-correct** | Nome colore (es: `"yellow"`, `"red"`) | `"true"` o `"false"` |
| **Quando** | Solo le parole corrette vanno sottolineate | Lo studente può sbagliare sottolineando parti sbagliate |
| **Validazione** | Controlla se ha sottolineato tutte le parole giuste | Controlla se ha sottolineato le parti giuste e NON quelle sbagliate |
| **Span cliccabili** | Solo le parole che DEVONO essere sottolineate | TUTTE le parti della frase (corrette E sbagliate) |
| **Esempio** | "Sottolinea gli attributi", "Cerchia i complementi" | "Sottolinea la frase principale", "Colora le coordinate" |

**⚠️ REGOLA CRITICA per TIPO 2 (frasi principali/secondarie):**
- ✅ **TUTTE** le parti della frase devono avere uno span con `data-word-highlighter-target="word"`
- ✅ Le parti CORRETTE (da sottolineare) hanno `data-correct="true"`
- ✅ Le parti SBAGLIATE (da NON sottolineare) hanno `data-correct="false"`
- ✅ **ENTRAMBE** le parti devono essere cliccabili
- ❌ NON lasciare testo plain senza span - lo studente deve poter cliccare tutto

**Esempio TIPO 2 completo (esercizio con frasi separate):**
```erb
<div data-controller="word-highlighter" data-word-highlighter-multi-color-value="false">
  <!-- Hidden color selector - OBBLIGATORIO -->
  <div class="hidden">
    <span data-word-highlighter-target="colorBox" data-color="red"></span>
  </div>

  <div class="space-y-3 cursor-pointer">
    <div class="bg-white border-2 border-purple-200 rounded-xl p-4">
      <!-- Frase principale (TRUE) e secondaria (FALSE) separate da spazio -->
      <span data-word-highlighter-target="word" data-correct="true" data-action="click->word-highlighter#toggleHighlight" class="px-1 rounded">Ti racconto una storia</span> <span data-word-highlighter-target="word" data-correct="false" data-action="click->word-highlighter#toggleHighlight" class="px-1 rounded">che ti piacerà molto.</span>
    </div>

    <div class="bg-white border-2 border-purple-200 rounded-xl p-4">
      <span data-word-highlighter-target="word" data-correct="false" data-action="click->word-highlighter#toggleHighlight" class="px-1 rounded">Ho i brividi</span> <span data-word-highlighter-target="word" data-correct="true" data-action="click->word-highlighter#toggleHighlight" class="px-1 rounded">perché fa freddo.</span>
    </div>
  </div>
</div>
```

**Modalità multicolore** (più colori):
```erb
<div data-controller="word-highlighter" data-word-highlighter-multi-color-value="true">
  <h2 class="text-lg md:text-xl font-bold text-gray-700 mb-4">
    <span class="bg-orange-500 text-white rounded-full w-8 h-8 md:w-10 md:h-10 inline-flex items-center justify-center mr-2">3</span>
    Sottolinea in <span class="text-purple-600 font-bold">viola<span class="inline-block w-6 h-6 bg-purple-300 rounded ml-1 align-middle cursor-pointer transition transform hover:scale-110" data-word-highlighter-target="colorBox" data-color="purple" data-action="click->word-highlighter#selectColor"></span></span> i nomi,
    in <span class="text-orange-600 font-bold">arancione<span class="inline-block w-6 h-6 bg-orange-300 rounded ml-1 align-middle cursor-pointer transition transform hover:scale-110" data-word-highlighter-target="colorBox" data-color="orange" data-action="click->word-highlighter#selectColor"></span></span> le apposizioni.
  </h2>

  <div class="space-y-4 cursor-pointer">
    <div class="bg-white p-4 rounded-lg">
      Mia <span data-word-highlighter-target="word"
                data-correct="orange"
                data-action="click->word-highlighter#toggleHighlight"
                class="px-1 rounded">zia</span> Francesca vive a Berlino.
    </div>
  </div>
</div>
```

**Attributi importanti**:
- `data-word-highlighter-multi-color-value`: `true` = multicolore, `false` = monocromatico
- `data-word-highlighter-target="word"`: identifica la parola/frase cliccabile
- `data-correct="yellow"`: TIPO 1 monocolor - specifica il colore da usare
- `data-correct="true"`: TIPO 2 monocolor - questa parte DEVE essere sottolineata
- `data-correct="false"`: TIPO 2 monocolor - questa parte NON deve essere sottolineata
- `data-correct="purple"` o `"orange"` ecc: multicolor mode, specifica il colore corretto
- **NON usare** `data-highlight-color` - usa solo `data-correct`
- `data-action="click->word-highlighter#toggleHighlight"`: azione al click
- **Hidden color selector**: OBBLIGATORIO in monocolor mode per far funzionare "Soluzioni"

**Quando usarlo**:
- ✅ TIPO 1: Sottolinea i nomi/verbi/aggettivi (solo parole corrette cliccabili)
- ✅ TIPO 2: Sottolinea la frase principale (tutte le frasi cliccabili con validazione true/false)
- ✅ TIPO 2: Colora le frasi coordinate (tutte cliccabili con true/false)
- ✅ Multicolor: Colora con colori diversi
- ✅ Cerchia le parole corrette

---

### 4. **syntagm-divider** (Dividi in Sintagmi)
**Uso**: Per esercizi "Dividi le frasi in sintagmi", divide frasi cliccando sugli spazi tra parole

**⚠️ REGOLE IMPORTANTI:**
- **Nel container**: aggiungi `cursor-pointer` al div che contiene gli esercizi
- **Sugli spazi**: NON mettere `hover:bg-*`, `hover:px-1`, `transition`, `cursor-pointer` sugli span individuali
- Può essere combinato con `word-highlighter` per cerchiare/sottolineare dopo aver diviso

**Uso base (solo divisione):**
```erb
<div data-controller="syntagm-divider">
  <h2 class="text-lg md:text-xl font-bold text-gray-700 mb-4">
    <span class="bg-orange-500 text-white rounded-full w-8 h-8 md:w-10 md:h-10 inline-flex items-center justify-center mr-2">2</span>
    Dividi le frasi in sintagmi e cancella quelli non indispensabili.
  </h2>

  <div class="space-y-3 cursor-pointer">
    <div class="bg-gray-50 border-2 border-gray-200 rounded-xl px-4 py-3">
      <span class="text-gray-700">• Mio<span data-syntagm-divider-target="divider" data-correct="false" data-action="click->syntagm-divider#toggleDivider"> </span>zio<span data-syntagm-divider-target="divider" data-correct="true" data-action="click->syntagm-divider#toggleDivider"> </span>abita<span data-syntagm-divider-target="divider" data-correct="true" data-action="click->syntagm-divider#toggleDivider"> </span>in<span data-syntagm-divider-target="divider" data-correct="false" data-action="click->syntagm-divider#toggleDivider"> </span>Polonia<span data-syntagm-divider-target="divider" data-correct="true" data-action="click->syntagm-divider#toggleDivider"> </span>da<span data-syntagm-divider-target="divider" data-correct="false" data-action="click->syntagm-divider#toggleDivider"> </span>sei<span data-syntagm-divider-target="divider" data-correct="false" data-action="click->syntagm-divider#toggleDivider"> </span>anni.</span>
    </div>
  </div>
</div>
```

**Uso combinato (divisione + sottolineatura):**
```erb
<div data-controller="word-highlighter syntagm-divider" data-word-highlighter-multi-color-value="true">
  <h2 class="text-lg md:text-xl font-bold text-gray-700 mb-4">
    <span class="bg-orange-500 text-white rounded-full w-8 h-8 md:w-10 md:h-10 inline-flex items-center justify-center mr-2">3</span>
    Dividi le frasi in sintagmi, poi cerchia di <span class="text-red-600 font-bold">rosso il predicato<span class="inline-block w-6 h-6 bg-red-300 rounded ml-1 align-middle cursor-pointer transition transform hover:scale-110" data-word-highlighter-target="colorBox" data-color="red" data-action="click->word-highlighter#selectColor"></span></span> e sottolinea di <span class="text-blue-600 font-bold">blu il soggetto<span class="inline-block w-6 h-6 bg-blue-300 rounded ml-1 align-middle cursor-pointer transition transform hover:scale-110" data-word-highlighter-target="colorBox" data-color="blue" data-action="click->word-highlighter#selectColor"></span></span> (se c'è).
  </h2>

  <div class="space-y-3 text-base md:text-lg cursor-pointer">
    <div class="bg-white border-2 border-yellow-200 rounded-xl px-4 py-3">
      <span class="text-gray-700">• <span data-word-highlighter-target="word" data-correct="blue" data-action="click->word-highlighter#toggleHighlight">L'amica</span><span data-syntagm-divider-target="divider" data-correct="false" data-action="click->syntagm-divider#toggleDivider"> </span>di<span data-syntagm-divider-target="divider" data-correct="false" data-action="click->syntagm-divider#toggleDivider"> </span>Ezzoura<span data-syntagm-divider-target="divider" data-correct="true" data-action="click->syntagm-divider#toggleDivider"> </span><span data-word-highlighter-target="word" data-correct="red" data-action="click->word-highlighter#toggleHighlight">assomiglia</span><span data-syntagm-divider-target="divider" data-correct="true" data-action="click->syntagm-divider#toggleDivider"> </span>all'attrice<span data-syntagm-divider-target="divider" data-correct="false" data-action="click->syntagm-divider#toggleDivider"> </span>di<span data-syntagm-divider-target="divider" data-correct="false" data-action="click->syntagm-divider#toggleDivider"> </span>un<span data-syntagm-divider-target="divider" data-correct="false" data-action="click->syntagm-divider#toggleDivider"> </span>film.</span>
    </div>
  </div>
</div>
```

**Attributi importanti**:
- `data-syntagm-divider-target="divider"`: identifica lo spazio cliccabile tra parole
- `data-correct="true"`: lo spazio deve essere diviso (barra verde)
- `data-correct="false"`: lo spazio NON deve essere diviso (barra rossa se cliccato)
- `data-action="click->syntagm-divider#toggleDivider"`: azione al click
- Gli span divider contengono solo uno spazio: `> </span>`

**Quando usarlo**:
- ✅ Dividi le frasi in sintagmi
- ✅ Separa i gruppi di parole
- ✅ Individua i sintagmi indispensabili
- ✅ Combina con word-highlighter per cerchiare soggetto/predicato dopo la divisione

---

### 5. **multiple-choice** (Scelta Multipla)
**Uso**: Per esercizi con scelta tra opzioni (radio button o checkbox)

```erb
<div data-controller="multiple-choice">
  <div class="space-y-3">
    <label class="flex items-center gap-3 p-3 bg-white rounded-lg cursor-pointer hover:bg-blue-50">
      <input type="radio"
             name="question1"
             data-multiple-choice-target="answer"
             data-correct-answer="true"
             class="w-5 h-5">
      <span>Opzione corretta</span>
    </label>

    <label class="flex items-center gap-3 p-3 bg-white rounded-lg cursor-pointer hover:bg-blue-50">
      <input type="radio"
             name="question1"
             data-multiple-choice-target="answer"
             data-correct-answer="false"
             class="w-5 h-5">
      <span>Opzione sbagliata</span>
    </label>
  </div>
</div>
```

**Attributi importanti**:
- `data-multiple-choice-target="answer"`: identifica l'opzione
- `data-correct-answer="true/false"`: indica se l'opzione è corretta
- `type="radio"`: per scelta singola
- `type="checkbox"`: per scelta multipla

**Quando usarlo**:
- ✅ Scegli la risposta corretta
- ✅ Vero o Falso
- ✅ Quale opzione è giusta?
- ✅ Seleziona tutte le risposte corrette

---

### 5. **exercise-group** (Gruppo di Esercizi)
**Uso**: Per raggruppare più esercizi correlati con controllo comune

```erb
<div data-controller="exercise-group">
  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
    <!-- Esercizio 1 -->
    <div class="bg-white p-4 rounded-lg">
      <input type="text"
             data-exercise-group-target="input"
             data-correct-answer="risposta1">
    </div>

    <!-- Esercizio 2 -->
    <div class="bg-white p-4 rounded-lg">
      <input type="text"
             data-exercise-group-target="input"
             data-correct-answer="risposta2">
    </div>
  </div>
</div>
```

**Quando usarlo**:
- ✅ Serie di esercizi simili da controllare insieme
- ✅ Griglia di completamenti
- ✅ Batteria di domande correlate

---

### 6. **word-choice** (Scelta tra Parole)
**Uso**: Per scegliere tra alternative di parole inline

```erb
<div data-controller="word-choice">
  <p class="text-lg">
    Il gatto
    <select data-word-choice-target="select"
            data-correct-answer="miagola"
            class="border-2 border-blue-400 rounded px-2">
      <option value="">---</option>
      <option value="miagola">miagola</option>
      <option value="abbaia">abbaia</option>
      <option value="cinguetta">cinguetta</option>
    </select>
    forte.
  </p>
</div>
```

**Quando usarlo**:
- ✅ Scegli la parola corretta tra parentesi
- ✅ Completa con l'opzione giusta

---

### 7. **image-speech** (Audio per Immagini)
**Uso**: Per pronuncia o audio associato a immagini

```erb
<div data-controller="image-speech">
  <%= image_tag "nvl5_gram_p022_01.jpg",
                class: "w-32 h-32 cursor-pointer",
                data: {
                  action: "click->image-speech#speak",
                  "image-speech-text": "parola da pronunciare"
                } %>
</div>
```

**Quando usarlo**:
- ✅ Ascolta e ripeti
- ✅ Pronuncia corretta
- ✅ Click sull'immagine per sentire l'audio

---

### 8. **drag-drop** / **sortable** (Trascina e Ordina)
**Uso**: Per ordinare elementi o trascinare

```erb
<div data-controller="sortable">
  <div class="space-y-2" data-sortable-target="container">
    <div class="p-3 bg-white rounded cursor-move"
         data-sortable-target="item"
         data-position="1">
      Primo elemento
    </div>
    <div class="p-3 bg-white rounded cursor-move"
         data-sortable-target="item"
         data-position="2">
      Secondo elemento
    </div>
  </div>
</div>
```

**Quando usarlo**:
- ✅ Metti in ordine
- ✅ Riordina la sequenza
- ✅ Trascina nella posizione corretta

---

## RIEPILOGO TIPOLOGIE ESERCIZI

| Tipo Esercizio | Controller | Parametri Chiave |
|----------------|------------|------------------|
| **Sottolinea parole (mono TIPO 1)** | `word-highlighter` | `multi-color-value="false"`, `data-correct="yellow"` + hidden color selector, SOLO parole corrette cliccabili |
| **Frasi principali/secondarie (mono TIPO 2)** | `word-highlighter` | `multi-color-value="false"`, `data-correct="true/false"` + hidden color selector, TUTTE le frasi cliccabili |
| **Sottolinea (multi)** | `word-highlighter` | `multi-color-value="true"`, `data-correct="red"` (NON data-highlight-color) |
| **Cerchia** | `word-highlighter` | `multi-color-value="false"`, `data-correct="yellow"` + hidden color selector |
| **Dividi sintagmi** | `syntagm-divider` | `data-correct="true/false"` sugli spazi tra parole |
| **Dividi + Cerchia** | `word-highlighter syntagm-divider` | Combinazione di entrambi i controller |
| **Completa** | `fill-blanks` | `data-correct-answer="risposta"` |
| **Completa (libera)** | `fill-blanks` | `data-correct-answer="libera"` |
| **Scegli (radio)** | `multiple-choice` | `type="radio"`, `data-correct-answer="true/false"` |
| **Scegli (checkbox)** | `multiple-choice` | `type="checkbox"` |
| **Vero/Falso** | `multiple-choice` | `type="radio"`, 2 opzioni |
| **Collega** | `word-choice` | `<select>` con `data-correct-answer` |
| **Ordina** | `sortable` | `data-position="n"` |
| **Audio** | `image-speech` | `data-image-speech-text` |
| **Gruppo** | `exercise-group` | Wrapper per esercizi correlati |

---

## NOTE IMPORTANTI

### ⚠️ REGOLE DI FORMATTAZIONE CRITICHE:

#### Titoli degli esercizi:
- ✅ **Struttura corretta**: `<h2>` con pallino, badge, e testo INLINE
- ✅ **Spacing**: usa `mr-2` tra elementi, NON `flex items-center flex-wrap gap-2`
- ✅ **Quadratini colorati**: INLINE con la parola (es: "attributo⬜"), non separati
- ❌ **NO**: wrapping con `<span>` del testo principale

Esempio corretto:
```erb
<h2 class="text-lg md:text-xl font-bold text-gray-700 mb-4">
  <span class="...rounded-full... mr-2">1</span>
  <span class="...badge... mr-2">IMPARARE TUTTI</span>
  Sottolinea le <strong class="underline">apposizioni<span class="...quadratino..."></span></strong>.
</h2>
```

#### Word Highlighter (Sottolinea/Cerchia):
- ✅ **Hidden color selector**: OBBLIGATORIO in monocolor mode
- ✅ **Container cursor**: `cursor-pointer` sul div container
- ✅ **Parole**: solo `class="px-1 rounded"`, NO hover, NO cursor, NO transition
- ✅ **data-correct TIPO 1**: usa il nome del colore ("yellow", "red", "purple") - solo parole corrette sono cliccabili
- ✅ **data-correct TIPO 2**: usa "true" o "false" - TUTTE le frasi sono cliccabili (per frasi principali/secondarie)
- ❌ **NO data-highlight-color**: usa solo `data-correct`

**⚠️ REGOLA CRITICA TIPO 2 (Frasi principali/secondarie):**
- ✅ TUTTE le frasi (principali E secondarie) DEVONO avere uno span cliccabile
- ✅ Frasi principali: `data-correct="true"`
- ✅ Frasi secondarie: `data-correct="false"`
- ❌ NON lasciare testo plain - lo studente deve poter cliccare tutto e anche sbagliare

#### Syntagm Divider (Dividi sintagmi):
- ✅ **Container cursor**: `cursor-pointer` sul div container
- ✅ **Spazi**: NO hover, NO px-1, NO transition, NO cursor sugli span
- ✅ **Content**: gli span divider contengono SOLO uno spazio: `> </span>`

#### Fill Blanks + Word Highlighter combinati:
- ✅ **Monocolor mode**: aggiungi hidden color selector
- ✅ **data-correct**: usa nome colore, non "true"
- ✅ **Input**: `data-fill-blanks-target="input"` e `data-correct-answer`

### ⚠️ Da Ricordare:
- **NO placeholder con puntini** (`......`) negli input
- **NO pulsanti verifica individuali** per esercizio
- **SI controllo globale** con `exercise-checker` wrapper
- **SI exercise_controls** per tutti i controlli
- **NO hover effects** sulle parole da evidenziare o sugli spazi da dividere
- **SI cursor-pointer** solo sul container principale dell'esercizio

### 🎨 Colori per Badge:
- **SINTASSI**: giallo/arancione
- **MORFOLOGIA**: blu/azzurro
- **LESSICO**: verde
- **ORTOGRAFIA**: rosso/rosa
- **VERIFICA**: viola

### 🎛️ Exercise Controls (Bottoni di Navigazione e Controllo):

**Parametri disponibili per `exercise_controls` partial:**
- `color`: Colore del tema (default: 'orange'). Opzioni: 'orange', 'blue', 'purple', 'green', 'pink', 'red', 'cyan'
- `show_exercise_buttons`: Mostra i bottoni di controllo esercizi (default: true)

**Quando usare `show_exercise_buttons: false`:**
- ✅ Pagine di sola teoria senza esercizi interattivi
- ✅ Pagine indice/sommario
- ✅ Pagine di introduzione
- ❌ Pagine con esercizi interattivi (lascia default `true`)

**Esempio per pagina con esercizi:**
```erb
<%= render 'shared/exercise_controls', color: 'orange' %>
```

**Esempio per pagina di teoria o indice:**
```erb
<%= render 'shared/exercise_controls', color: 'purple', show_exercise_buttons: false %>
```

**Cosa viene nascosto con `show_exercise_buttons: false`:**
- Bottone "Ricomincia" (reset)
- Bottone "Controlla" (verifica risposte)
- Bottone "Soluzioni" (mostra soluzioni)
- Bottone "MAIUSCOLO" (text toggle)
- Bottone "Leggi" (text-to-speech)

**Cosa rimane sempre visibile:**
- Frecce di navigazione (← pagina precedente, pagina successiva →)

### 📝 Convenzioni Naming:
- File ERB: `nvl5_gram_p[numero].html.erb`
- Immagini: `nvl5_gram_p[numero]_[nn].jpg`
- Slug/Route: `nvl5_gram_p[numero]`

---

## ESEMPIO PROMPT MINIMO (File Già Importati)

```
Crea pagina 111 dai file in app/assets/images/nvl5_gram/p111/
Usa page.png per la grafica, exercise-checker globale, no pulsanti individuali.
```

## ESEMPIO PROMPT MINIMO (File Originali)

```
Crea pagina 111 dai file in /home/paolotax/Windows/book_844/
Usa HTML e PNG per struttura, exercise-checker globale, no pulsanti individuali.
```

## ESEMPIO PROMPT DETTAGLIATO (File Già Importati)

```
Crea pagina 111 da app/assets/images/nvl5_gram/p111/

Implementa:
1. Esercizio 1: sottolinea con word-highlighter
2. Esercizio 2: completa con fill-blanks (risposte specifiche)
3. Esercizio 3: cerchia con checkbox

Usa exercise-checker globale, no pulsanti individuali.
Aggiungi al seed e rigenera database.
```

## ESEMPIO PROMPT DETTAGLIATO (File Originali)

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