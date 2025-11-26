# 📊 SCHEMA COMPLETO CONTROLLER STIMULUS - ANALISI DEFINITIVA

**Data analisi**: 2025-11-11
**Ultimo aggiornamento**: 2025-11-11 - Eliminati: plurals_controller.js, hello_controller.js, word_classifier_controller.js
**Totale controller**: 30 (era 33)
**Path sorgenti**: `/app/javascript/controllers/`
**Totale pagine exercises**: 185

---

## 🏆 TOP 10 - Controller Più Utilizzati

| # | Controller | Utilizzi | Note |
|---|------------|----------|------|
| 1 | **exercise-checker** | 168 | Controller orchestratore master |
| 2 | **fill-blanks** | 166 | Riempimento spazi vuoti |
| 3 | **word-highlighter** | 70+ | Evidenziazione parole (anche combinato) |
| 4 | **exercise-group** | 57 | Selezione gruppi con colorazione |
| 5 | **multiple-choice** | 38+ | Radio button con correzione |
| 6 | **image-speech** | 38 | TTS per immagini/parole |
| 7 | **audio-player** | 16 | Player audio |
| 8 | **card-selector** | 14 | Selezione card |
| 9 | **word-choice** | 6 | Scelta parole con barramento |
| 10 | **auto-advance** | 4 | Auto-avanzamento input |

---

## 📁 CONTROLLER PER CATEGORIA

### 🎯 **ORCHESTRATORI & UTILITY**

| Controller | Utilizzi | Posizione | Descrizione |
|------------|----------|-----------|-------------|
| **exercise_checker** | 168 | Exercises | Master che coordina tutti gli altri controller. Verifica risposte, mostra soluzioni, reset globale |
| **controller_checker** | 0 (layout?) | Layout | Mostra/nasconde bottoni basandosi sulla presenza di altri controller |
| **auto_advance** | 4 | Exercises | Auto-avanzamento automatico tra campi input (es. cruciverba) |

**File**: `exercise_checker_controller.js`, `controller_checker_controller.js`, `auto_advance_controller.js`

---

### ✍️ **INPUT & FORM**

| Controller | Utilizzi | File tipici | Descrizione |
|------------|----------|-------------|-------------|
| **fill_blanks** | 167 | nvl5_gram_*, nvl_4_gr_pag009 | Riempimento spazi vuoti con correzione e feedback |
| ~~**plurals**~~ | ~~1~~ | ~~Grammatica~~ | ~~ELIMINATO - era identico a fill-blanks~~ |
| **column_input** | 0 (partial) | _column_addition.html.erb | Navigazione tastiera per operazioni in colonna (frecce, tab) |
| **column_subtraction** | 0 (partial) | _column_subtraction.html.erb | Sottrazioni con prestiti e barramento cifre |
| **crossword** | 2 | Grammatica | Cruciverba interattivo con auto-avanzamento |

**File**: `fill_blanks_controller.js`, `plurals_controller.js`, `column_input_controller.js`, `column_subtraction_controller.js`, `crossword_controller.js`

**Note uniformazione possibile**:
- ⚠️ `plurals_controller.js` è identico a `fill_blanks` → **candidato a eliminazione**

---

### 🎨 **SELEZIONE & EVIDENZIAZIONE**

| Controller | Utilizzi | File tipici | Descrizione |
|------------|----------|-------------|-------------|
| **word_highlighter** | 70+ | nvl5_gram_*, nvi4_sto_* | Evidenzia parole con colori multipli (toggle on/off) |
| **card_selector** | 14 | nvl5_gram_*, pag008-041 | Selezione singola card con evidenziazione (radio behavior) |
| **exercise_group** | 57 | nvl5_gram_*, pag* | Gruppo opzioni con colorazione condizionale e checkmark |
| **word_choice** | 6 | nvl5_gram_* | Scelta tra alternative con line-through sulle scartate |
| **word_selector** | 1 | nvl5_gram_p054 | Selezione parola con feedback immediato verde/rosso |
| **multiple_choice** | 38+ | Molte pagine | Radio button con verifica risposta corretta/sbagliata |
| **error_finder** | 1 | nvi4_sto_p155 | Trova errori in parole, evidenzia e mostra hint |

**File**: `word_highlighter_controller.js`, `card_selector_controller.js`, `exercise_group_controller.js`, `word_choice_controller.js`, `word_selector_controller.js`, `error_finder_controller.js`

**Note uniformazione possibile**:
- ⚠️ `card_selector`, `exercise_group` e `word_selector` hanno funzionalità simili → **candidati a unificazione**
- ⚠️ `word_choice` potrebbe essere unificato con `word_selector`

---

### 🔊 **AUDIO & TEXT-TO-SPEECH**

| Controller | Utilizzi | File tipici | Descrizione |
|------------|----------|-------------|-------------|
| **audio_player** | 16 | nvl5_gram_*, nvl5_gr_* | Player audio con feedback visivo durante riproduzione |
| **text_to_speech** | 1+ | Combinato con altri | TTS completo con evidenziazione parole durante lettura |
| **image_speech** | 38 | nvl5_gram_p022, pag010gen, pag050/051/167 | TTS per pronuncia singole parole/immagini |
| **text_toggle** | 2+ | Varie pagine | Toggle maiuscolo/minuscolo del testo |

**File**: `audio_player_controller.js`, `text_to_speech_controller.js`, `image_speech_controller.js`, `text_toggle_controller.js`

**Note uniformazione possibile**:
- ⚠️ `text_to_speech` e `image_speech` potrebbero condividere codice comune

---

### 🎮 **GIOCHI & MATCHING**

| Controller | Utilizzi | File tipici | Descrizione |
|------------|----------|-------------|-------------|
| **flower_matcher** | 4 | bus3_mat_*, nvi5_mat_* | Collegamento elementi con linee SVG (matching visuale) |
| **sentence_matcher** | 1 | nvi4_sto_p155 | Collegamento frasi con linee SVG |
| **word_sorter** | 1 | nvl_4_gr_pag014 | Ordinamento parole con drag & drop |
| **phrase_drop** | 1 | nvi4_sto_p155 | Drag & drop frasi in textarea |
| **rhyme_highlighter** | 2+ | Combinato | Evidenziazione rime con colori diversi |

**File**: `flower_matcher_controller.js`, `sentence_matcher_controller.js`, `word_sorter_controller.js`, `phrase_drop_controller.js`, `rhyme_highlighter_controller.js`

**Note uniformazione possibile**:
- ⚠️ `flower_matcher` e `sentence_matcher` usano stesso pattern SVG → **candidati a unificazione**
- ⚠️ `word_sorter` e `phrase_drop` usano stesso drag&drop → **candidati a unificazione**
- ⚠️ `rhyme_highlighter` è simile a `word_highlighter` → **valutare unificazione**

---

### 📐 **MATEMATICA**

| Controller | Utilizzi | File tipici | Descrizione |
|------------|----------|-------------|-------------|
| **column_modal** | 3 | bus3_mat_p025/026/032 | Modal per addizioni in colonna con griglia dinamica |
| **column_input** | partial | _column_addition.html.erb | Navigazione tastiera operazioni colonna |
| **column_subtraction** | partial | _column_subtraction.html.erb | Sottrazioni con prestiti e line-through |
| **fraction_grids** | 1 | bus3_mat_p075 | Frazioni con griglie cliccabili |
| **fraction_circles** | 1 | bus3_mat_p075 | Frazioni con cerchi/spicchi SVG |

**File**: `column_modal_controller.js`, `column_input_controller.js`, `column_subtraction_controller.js`, `fraction_grids_controller.js`, `fraction_circles_controller.js`

**Note uniformazione possibile**:
- ⚠️ `fraction_grids` e `fraction_circles` hanno logica simile → **candidati a unificazione**

---

### 🔤 **ANALISI LINGUISTICA**

| Controller | Utilizzi | File tipici | Descrizione |
|------------|----------|-------------|-------------|
| **syntagm_divider** | 1+ | Combinato con word-highlighter | Divisione sintagmi con slash cliccabili |
| ~~**word_classifier**~~ | ~~1~~ | ~~nvl_4_gr_pag008~~ | ~~ELIMINATO - controller vuoto, non serviva~~ |

**File**: `syntagm_divider_controller.js`, ~~`word_classifier_controller.js`~~

**Note uniformazione possibile**:
- ✅ `word_classifier` era vuoto → **ELIMINATO (2025-11-11)**

---

### 📱 **NAVIGAZIONE & UI**

| Controller | Utilizzi | File tipici | Descrizione |
|------------|----------|-------------|-------------|
| **sidebar_controller** | Layout | _sidebar.html.erb | Sidebar responsive con stato persistente (localStorage) |
| **sidebar_nav** | Layout | _sidebar.html.erb | Navigazione gerarchica a 3 stati con breadcrumb |
| **sidebar_breadcrumb** | Non usato | - | Sistema breadcrumb alternativo (mai utilizzato) |
| **slide_menu** | Layout | application.html.erb | Menu laterale con overlay |

**File**: `sidebar_controller.js`, `sidebar_nav_controller.js`, `sidebar_breadcrumb_controller.js`, `slide_menu_controller.js`

**Note uniformazione possibile**:
- ⚠️ `sidebar_nav` e `sidebar_breadcrumb` hanno funzionalità sovrapposte → **uno dei due può essere eliminato**
- ℹ️ `sidebar_controller` e `slide_menu` potrebbero essere lo stesso → **verificare**

---

### 🔧 **SVILUPPO & TEST**

| Controller | Utilizzi | Note |
|------------|----------|------|
| **hello** | 0 | Controller demo/esempio Stimulus (non utilizzato in produzione) |

**File**: `hello_controller.js`

**Note**: Può essere eliminato o tenuto come riferimento per sviluppatori

---

## 📊 STATISTICHE FINALI

**Totale controller**: 30 (erano 33, eliminati 3)
**Controller utilizzati attivamente**: 29
**Controller mai usati direttamente**: 1 (sidebar_breadcrumb)
**Controller in partial**: 2 (column_input, column_subtraction)
**Controller in layout**: 3-4 (sidebar_*, slide_menu)

**Eliminazioni completate**: 3
- ✅ plurals_controller.js (duplicato di fill-blanks)
- ✅ hello_controller.js (demo non usato)
- ✅ word_classifier_controller.js (vuoto, non serviva)

---

## 🔄 PATTERN DI UTILIZZO COMBINATO

Controller spesso usati insieme nella stessa pagina:

| Combinazione | Occorrenze | Caso d'uso |
|--------------|------------|------------|
| `exercise-checker` + altri | 168 | Orchestratore master presente ovunque |
| `word-highlighter` + `syntagm-divider` | 5 | Analisi linguistica avanzata |
| `word-highlighter` + `multiple-choice` | 2 | Esercizi misti evidenziazione + scelta |
| `word-highlighter` + `fill-blanks` | 2 | Evidenziazione + completamento |
| `exercise-checker` + `text-toggle` + `text-to-speech` + `rhyme-highlighter` | 1 | Pagina poesia completa |
| `exercise-checker` + `fraction-grids` | 1 | Esercizi matematica frazioni |

---

## 🎯 RACCOMANDAZIONI PER UNIFORMAZIONE

### ⭐ **ALTA PRIORITÀ** - Eliminazioni sicure

1. ✅ **plurals_controller.js** → ~~Identico a `fill_blanks_controller.js`~~
   - ✅ Sostituito in nvl_4_gr_pag009.html.erb con `fill-blanks`
   - ✅ File eliminato (2025-11-11)

2. ✅ **hello_controller.js** → ~~Controller demo non utilizzato~~
   - ✅ File eliminato (2025-11-11)

3. ✅ **word_classifier_controller.js** → ~~Quasi vuoto, solo console.log~~
   - ✅ Rimosso riferimento da nvl_4_gr_pag008.html.erb (usava già card-selector)
   - ✅ File eliminato (2025-11-11)

### ⭐ **MEDIA PRIORITÀ** - Unificazioni consigliate

4. **card_selector + exercise_group + word_selector** → Funzionalità simili
   - Creare controller unificato `option_selector_controller.js`
   - Supportare diversi comportamenti tramite parametri

5. **flower_matcher + sentence_matcher** → Stesso pattern SVG matching
   - Creare controller unificato `svg_matcher_controller.js`
   - Parametrizzare tipo di elementi da collegare

6. **word_sorter + phrase_drop** → Stesso drag & drop
   - Creare controller unificato `drag_drop_controller.js`
   - Parametrizzare tipo di elementi

7. **fraction_grids + fraction_circles** → Logica frazioni simile
   - Creare controller unificato `fraction_visualizer_controller.js`
   - Parametrizzare tipo di visualizzazione (griglia/cerchio)

8. **sidebar_nav vs sidebar_breadcrumb** → Uno dei due non usato
   - Decidere quale mantenere
   - Eliminare l'altro

### ⭐ **BASSA PRIORITÀ** - Refactoring opzionali

9. **word_highlighter + rhyme_highlighter** → Pattern simile
   - Valutare unificazione con parametri
   - `rhyme_highlighter` aggiunge logica di verifica raggruppamenti

10. **text_to_speech + image_speech** → Codice TTS comune
    - Estrarre logica comune in classe base
    - Specializzare per caso d'uso

11. **word_choice + word_selector** → Pattern selezione simile
    - `word_choice` usa line-through
    - `word_selector` usa colori
    - Valutare unificazione con parametro `feedback_style`

---

## 📍 MAPPA DEI FILE

### Sorgenti Controller
```
/app/javascript/controllers/
├── exercise_checker_controller.js       ⭐ MASTER ORCHESTRATOR
├── fill_blanks_controller.js            ⭐ MOLTO USATO
├── word_highlighter_controller.js       ⭐ MOLTO USATO
├── exercise_group_controller.js         ⭐ MOLTO USATO
├── multiple_choice_controller.js        ⭐ MOLTO USATO
├── image_speech_controller.js           ⭐ MOLTO USATO
├── audio_player_controller.js
├── card_selector_controller.js
├── word_choice_controller.js
├── auto_advance_controller.js
├── flower_matcher_controller.js
├── sentence_matcher_controller.js
├── word_sorter_controller.js
├── phrase_drop_controller.js
├── rhyme_highlighter_controller.js
├── column_modal_controller.js
├── column_input_controller.js
├── column_subtraction_controller.js
├── fraction_grids_controller.js
├── fraction_circles_controller.js
├── syntagm_divider_controller.js
├── ~~word_classifier_controller.js~~    ❌ ELIMINATO
├── text_to_speech_controller.js
├── text_toggle_controller.js
├── error_finder_controller.js
├── crossword_controller.js
├── ~~plurals_controller.js~~            ❌ ELIMINATO
├── sidebar_controller.js
├── sidebar_nav_controller.js
├── sidebar_breadcrumb_controller.js     ⚠️ NON USATO
├── slide_menu_controller.js
├── word_selector_controller.js
├── controller_checker_controller.js
└── ~~hello_controller.js~~              ❌ ELIMINATO
```

### Utilizzo nelle View
```
/app/views/
├── exercises/*.html.erb                 (185 file)
├── shared/
│   ├── _exercise_controls.html.erb      (Controlli comuni)
│   ├── _column_addition.html.erb        (usa column-input)
│   ├── _column_subtraction.html.erb     (usa column-subtraction)
│   └── _sidebar.html.erb                (usa sidebar-*)
└── layouts/
    └── application.html.erb             (usa sidebar/slide-menu)
```

---

## 🔍 COMANDI UTILI PER ANALISI

```bash
# Trova tutti i controller usati
grep -h 'data-controller=' app/views/exercises/*.html.erb | grep -o 'data-controller="[^"]*"' | sort | uniq -c | sort -rn

# Cerca dove è usato un controller specifico
grep -l 'data-controller="[^"]*NOME_CONTROLLER' app/views/**/*.html.erb

# Conta utilizzi di un controller
grep -r 'data-controller="[^"]*NOME_CONTROLLER' app/views/exercises/ | wc -l

# Trova controller combinati
grep 'data-controller=' app/views/exercises/*.html.erb | grep -E '(word-highlighter|exercise-group)' | head -20
```

---

## 📝 NOTE FINALI

- Questo report è stato generato analizzando 185 pagine di esercizi
- Alcuni controller sono usati solo in partial condivisi (column_input, column_subtraction)
- Il controller `exercise_checker` è il cuore del sistema e coordina tutti gli altri
- Pattern dominante: controller specializzati che lavorano insieme in modo orchestrato
- Opportunità di refactoring: circa 10-12 controller potrebbero essere unificati

**Mantenuto da**: Claude Code
**Ultimo aggiornamento**: 2025-11-11
