# Prompt per Pagine PAROLE AL CENTRO con Hotspot

Pagine interattive con immagini e hotspot cliccabili per la sintesi vocale delle parole.

---

## COS'È UNA PAGINA PAROLE AL CENTRO

Una pagina PAROLE AL CENTRO è una vista interattiva che presenta:
- Un'**immagine principale** (es. biblioteca, supermercato, palestra)
- **Hotspot cliccabili** sovrapposti sull'immagine in posizioni precise
- **Sintesi vocale** che legge la parola quando si clicca su un hotspot
- **Editor visuale** per posizionare e ridimensionare gli hotspot (modalità edit)

### Esempi Esistenti
- `nvl5_gram_p004.html.erb` - IN BIBLIOTECA (tema rosa)
- `nvl5_gram_p022.html.erb` - AL SUPERMERCATO (tema blu)
- `nvl5_gram_p040.html.erb` - IN PALESTRA (tema verde)
- `nvl5_gram_p100.html.erb` - NEL NEGOZIO DI ABBIGLIAMENTO (tema arancione)

---

## PROMPT RAPIDO

```
Crea una pagina PAROLE AL CENTRO dall'immagine [nome_file].jpg che trovi in ~/Downloads/[cartella]/

Ambiente: [descrizione luogo, es. "biblioteca", "supermercato", "palestra"]
Parole: [elenco parole/etichette da posizionare]
Colore tema: [pink/blue/green/orange/purple/cyan]
```

### Esempio:
```
Crea una pagina PAROLE AL CENTRO dall'immagine nvl5_gram_p120.jpg che trovi in ~/Downloads/nvl5_gram_p120/

Ambiente: ufficio postale
Parole: francobollo, pacco, lettera, cassetta postale, sportello, impiegato, busta, bilancia, modulo
Colore tema: blue
```

---

## STRUTTURA TECNICA

### 1. Container Principale
```erb
<div class="max-w-6xl mx-auto p-3 md:p-8 bg-gradient-to-br from-blue-50 via-white to-blue-50 rounded-3xl shadow-xl">
```

### 2. Header della Pagina
```erb
<!-- Header -->
<%= render 'shared/page_header', pagina: @pagina %>

<div class="mb-6">
  <p class="text-sm md:text-base text-blue-700">
    Osserva l'immagine del [luogo] e tocca i cartellini per ascoltare la parola corretta.
  </p>
</div>
```

### 3. Container Immagine con Hotspot Editor
```erb
<!-- Interactive Image -->
<div class="relative rounded-2xl overflow-hidden border-4 border-blue-200 shadow-2xl"
     data-controller="hotspot-editor"
     data-hotspot-editor-target="container">

  <%= image_tag "nvl5_gram/p022/p022_01.jpg",
      alt: "Supermercato con cartellini: frigorifero, scaffale, cassa...",
      class: "w-full h-full object-cover select-none pointer-events-none" %>

  <div class="absolute inset-0">
    <!-- Hotspots qui -->
  </div>
</div>
```

### 4. Array Hotspots
```erb
<% hotspots = [
  { label: "Frigorifero", top: "22.8%", left: "12.0%", width: "11.0%", height: "3.5%" },
  { label: "Scaffale", top: "35.6%", left: "32.8%", width: "9.1%", height: "3.5%" },
  { label: "Cassa", top: "52.0%", left: "78.0%", width: "7.5%", height: "3.5%" }
] %>
```

**IMPORTANTE**: Le posizioni sono in **percentuali** relative al container, non in pixel!

### 5. Loop Hotspots
```erb
<% hotspots.each do |hotspot| %>
  <button type="button"
          class="absolute rounded-xl bg-blue-500/10 hover:bg-blue-500/25 border-2 border-transparent hover:border-blue-500 focus:border-blue-600 focus:outline-none transition shadow-sm cursor-move"
          style="top: <%= hotspot[:top] %>; left: <%= hotspot[:left] %>; width: <%= hotspot[:width] %>; height: <%= hotspot[:height] %>;"
          aria-label="Leggi: <%= hotspot[:label] %>"
          data-controller="image-speech"
          data-hotspot-editor-target="hotspot"
          data-image-speech-word-value="<%= hotspot[:label] %>"
          data-image-speech-lang-value="it-IT"
          data-action="mousedown->hotspot-editor#startDrag click->image-speech#speak">
    <span class="sr-only"><%= hotspot[:label] %></span>
  </button>
<% end %>
```

### 6. Exercise Controls (sempre in fondo)
```erb
<!-- Exercise Controls -->
<div class="mt-6">
  <%= render 'shared/exercise_controls', color: 'blue', show_exercise_buttons: false %>
</div>
```

---

## CONTROLLER STIMULUS

### hotspot-editor (Editor Visuale)
**Path**: `app/javascript/controllers/hotspot_editor_controller.js`

**Funzionalità**:
- Drag & drop degli hotspot per riposizionarli
- Resize degli hotspot con maniglia in basso a destra
- Toggle tra modalità View (semi-trasparenti) e Edit (completamente visibili)
- Panel con valori copiabili per aggiornare il sorgente
- Pulsante fisso "✏️ Edit Hotspots" in basso a destra

**Uso**:
1. Clicca su "✏️ Edit Hotspots" per entrare in modalità edit
2. Trascina gli hotspot nella posizione corretta
3. Ridimensiona usando la maniglia bianca in basso a destra
4. Il panel mostra i valori in tempo reale
5. Clicca "Copy" per copiare il codice
6. Incolla nel sorgente ERB sostituendo l'array hotspots
7. Clicca "Close" o "👁️ View Mode" per uscire

### image-speech (Sintesi Vocale)
**Path**: `app/javascript/controllers/image_speech_controller.js`

**Funzionalità**:
- Legge ad alta voce la parola dell'hotspot quando cliccato
- Supporta diverse lingue (default: it-IT)

---

## WORKFLOW CREAZIONE PAGINA

### Step 1: Analizza l'Immagine
1. Leggo l'immagine principale
2. Identifico tutte le parole/etichette visibili
3. Conto quante etichette ci sono

### Step 2: Crea la View
1. Copio l'immagine in `app/assets/images/[libro]/p[numero]/`
2. Creo la view `.html.erb` con:
   - Header con partial `page_header`
   - Container immagine con controller `hotspot-editor`
   - Array hotspots con **posizioni iniziali approssimative**
   - Loop per generare i button hotspot
   - Exercise controls in fondo

### Step 3: Aggiorna il Seed
```ruby
Pagina.find_or_create_by!(slug: "nvl5_gram_p022") do |p|
  p.numero = 22
  p.volume = volume_nvl5_gram
  p.titolo = "AL SUPERMERCATO"
  p.sottotitolo = "PAROLE AL CENTRO"
  p.base_color = "blue"
  p.esercizi_data = {}
end
```

### Step 4: Rigenera Database
```bash
rails db:reset
```

### Step 5: Posizionamento Preciso (con Editor)
1. Vai alla pagina nel browser
2. Clicca "✏️ Edit Hotspots"
3. Sposta e ridimensiona ogni hotspot
4. Copia i valori dal panel
5. Incolla nel sorgente ERB
6. Ricarica la pagina per verificare

---

## TEMI COLORE DISPONIBILI

### Rosa (Pink)
```erb
bg-gradient-to-br from-pink-50 via-white to-red-50
border-pink-200
bg-pink-500/10 hover:bg-pink-500/25
border-pink-500
text-pink-700
color: 'pink'
```

### Blu (Blue)
```erb
bg-gradient-to-br from-blue-50 via-white to-orange-50
border-blue-200
bg-blue-500/10 hover:bg-blue-500/25
border-blue-500
text-blue-700
color: 'blue'
```

### Verde (Green)
```erb
bg-gradient-to-br from-green-50 via-white to-green-50
border-green-200
bg-green-500/10 hover:bg-green-500/25
border-green-500
text-green-700
color: 'green'
```

### Arancione (Orange)
```erb
bg-gradient-to-br from-orange-50 via-white to-orange-50
border-orange-200
bg-orange-500/10 hover:bg-orange-500/25
border-orange-500
text-orange-700
color: 'orange'
```

---

## DETTAGLI TECNICI IMPORTANTI

### Opacità Hotspot
- **View Mode**: `bg-blue-500/10` (semi-trasparente, 10% opacità)
- **Edit Mode**: `bg-blue-500` (completamente visibile, 100% opacità)

Il controller `hotspot-editor` gestisce automaticamente il toggle usando regex:
```javascript
// Rimuove /10
hotspot.className = currentBg.replace(/bg-(\w+)-(\d+)\/10/, 'bg-$1-$2')

// Aggiunge /10
hotspot.className = currentBg.replace(/bg-(\w+)-(\d+)(?!\/)/, 'bg-$1-$2/10')
```

### Posizionamento Percentuale
Tutte le coordinate sono in **percentuali** per garantire responsive:
- `top`: distanza dal bordo superiore dell'immagine (%)
- `left`: distanza dal bordo sinistro dell'immagine (%)
- `width`: larghezza dell'hotspot (%)
- `height`: altezza dell'hotspot (%)

### Resize Handles
Maniglie bianche circolari aggiunte dinamicamente dal controller:
- Visibili solo in edit mode
- Posizionate in basso a destra (`bottom-0 right-0`)
- Cursor: `cursor-nwse-resize`

### Accessibilità
```erb
aria-label="Leggi: <%= hotspot[:label] %>"
<span class="sr-only"><%= hotspot[:label] %></span>
```
Screen reader friendly: la label è visibile solo agli assistenti vocali.

---

## TEMPLATE COMPLETO

```erb
<div class="max-w-6xl mx-auto p-3 md:p-8 bg-gradient-to-br from-COLORE-50 via-white to-COLORE-50 rounded-3xl shadow-xl">

  <!-- Header -->
  <%= render 'shared/page_header', pagina: @pagina %>

  <div class="mb-6">
    <p class="text-sm md:text-base text-COLORE-700">
      Osserva l'immagine del [LUOGO] e tocca i cartellini per ascoltare la parola corretta.
    </p>
  </div>

  <!-- Interactive Image -->
  <div class="relative rounded-2xl overflow-hidden border-4 border-COLORE-200 shadow-2xl"
       data-controller="hotspot-editor"
       data-hotspot-editor-target="container">
    <%= image_tag "LIBRO/pNUMERO/pNUMERO_01.jpg",
        alt: "[Descrizione con elenco completo delle parole]",
        class: "w-full h-full object-cover select-none pointer-events-none" %>

    <div class="absolute inset-0">
      <% hotspots = [
        { label: "Parola1", top: "10%", left: "10%", width: "10%", height: "3.5%" },
        { label: "Parola2", top: "20%", left: "20%", width: "10%", height: "3.5%" }
      ] %>

      <% hotspots.each do |hotspot| %>
        <button type="button"
                class="absolute rounded-xl bg-COLORE-500/10 hover:bg-COLORE-500/25 border-2 border-transparent hover:border-COLORE-500 focus:border-COLORE-600 focus:outline-none transition shadow-sm cursor-move"
                style="top: <%= hotspot[:top] %>; left: <%= hotspot[:left] %>; width: <%= hotspot[:width] %>; height: <%= hotspot[:height] %>;"
                aria-label="Leggi: <%= hotspot[:label] %>"
                data-controller="image-speech"
                data-hotspot-editor-target="hotspot"
                data-image-speech-word-value="<%= hotspot[:label] %>"
                data-image-speech-lang-value="it-IT"
                data-action="mousedown->hotspot-editor#startDrag click->image-speech#speak">
          <span class="sr-only"><%= hotspot[:label] %></span>
        </button>
      <% end %>
    </div>
  </div>

  <!-- Exercise Controls -->
  <div class="mt-6">
    <%= render 'shared/exercise_controls', color: 'COLORE', show_exercise_buttons: false %>
  </div>
</div>
```

**Sostituisci**:
- `COLORE` con il colore tema (pink, blue, green, orange, purple, cyan)
- `LIBRO` con lo slug del libro (es. nvl5_gram)
- `NUMERO` con il numero pagina (es. 022)
- `[LUOGO]` con la descrizione dell'ambiente
- Array `hotspots` con le posizioni reali (usa l'editor!)

---

## ESEMPI REALI

### Esempio 1: Biblioteca (Pagina 4)
```
Volume: Nuovi Volentieri 5 Grammatica
Pagina: 4
Ambiente: Biblioteca
Tema colore: Rosa (pink)
Parole: Finestra, Manifesto, Scala, Scaffale, Lampada, Quaderno, Tavolo, Libro,
        Sedia, Cuscino, Tappeto, Poltrona, Schermo interattivo, Bibliotecaria
```

**View**: `app/views/exercises/nvl5_gram_p004.html.erb`
**Immagine**: `app/assets/images/nvl5_gram/p004/p04_01.jpg`

### Esempio 2: Supermercato (Pagina 22)
```
Volume: Nuovi Volentieri 5 Grammatica
Pagina: 22
Ambiente: Supermercato
Tema colore: Blu (blue)
Parole: Frigorifero, Cartello del reparto, Lampadario, Scaffale, Flaconi, Espositore,
        Capo reparto, Cassa, Scatole, Cliente, Cestino, Bilancia, Cassetta, Borse,
        Banco, Carrello, Corsia
```

**View**: `app/views/exercises/nvl5_gram_p022.html.erb`
**Immagine**: `app/assets/images/nvl5_gram/p022/p022_01.jpg`

### Esempio 3: Palestra (Pagina 40)
```
Volume: Nuovi Volentieri 5 Grammatica
Pagina: 40
Ambiente: Palestra
Tema colore: Verde (green)
Parole: Tabellone, Canestro, Muri, Spalliera, Pioli, Quadro svedese, Pallone,
        Materassaccio, Cerchio, Tuta da ginnastica, Materassone, Materassino,
        Clavette, Corda, Trave
```

**View**: `app/views/exercises/nvl5_gram_p040.html.erb`
**Immagine**: `app/assets/images/nvl5_gram/p040/p040_01.jpg`

---

## TROUBLESHOOTING

### Gli hotspot non sono posizionati bene
**Soluzione**: Usa l'editor visuale:
1. Vai alla pagina
2. Clicca "✏️ Edit Hotspots"
3. Sposta/ridimensiona
4. Copia i valori e incollali nel sorgente

### L'audio non funziona
**Verifica**:
- Controller `image-speech` è caricato?
- Attributo `data-image-speech-word-value` è corretto?
- La lingua è impostata su `it-IT`?

### Il pulsante edit non appare
**Verifica**:
- Controller `hotspot-editor` è caricato?
- Attributo `data-controller="hotspot-editor"` sul container?
- Attributo `data-hotspot-editor-target="container"` sul container?

### Gli hotspot non si trascinano
**Verifica**:
- Attributo `data-hotspot-editor-target="hotspot"` sui button?
- Action `mousedown->hotspot-editor#startDrag` è presente?
- Classe `cursor-move` è presente?

---

## COSA MI SERVE DA TE

**MINIMO INDISPENSABILE:**
1. ✅ Path immagine principale
2. ✅ Descrizione ambiente (biblioteca, supermercato, etc.)
3. ✅ Elenco completo delle parole da posizionare
4. ✅ Colore tema desiderato

**OPZIONALE:**
5. ⚠️ Posizioni precise (altrimenti uso l'editor dopo)
6. ⚠️ Note su particolarità della pagina

**Il resto lo faccio io! 🚀**

---

## CHECKLIST FINALE

Prima di considerare la pagina completa:

- [ ] Immagine copiata in `app/assets/images/[libro]/p[numero]/`
- [ ] View creata con controller `hotspot-editor` e `image-speech`
- [ ] Seed aggiornato con dati pagina
- [ ] Database rigenerato (`rails db:reset`)
- [ ] Posizioni hotspot aggiustate con l'editor visuale
- [ ] Array hotspots nel sorgente aggiornato con posizioni finali
- [ ] Attributo `alt` dell'immagine completo e descrittivo
- [ ] Exercise controls presente in fondo alla pagina
- [ ] Testata sintesi vocale su ogni hotspot
- [ ] Testata modalità edit/view
- [ ] Verificato responsive su mobile
