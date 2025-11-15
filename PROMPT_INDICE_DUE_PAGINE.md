# Prompt per Creare Indice a Due Pagine

Layout indice interattivo a due pagine affiancate che simula un libro aperto.

---

## COS'È UN INDICE A DUE PAGINE

Un indice a due pagine è una vista speciale che presenta:
- **Layout a due colonne** che simula un libro aperto (pagina sinistra e destra)
- **Navigazione gerarchica** con sezioni tematiche colorate
- **Link cliccabili** a tutte le pagine del volume
- **Badge speciali** per VERIFICA, IMPARARE TUTTI, etc.
- **Icone emoji** per pagine speciali (💬 per PAROLE AL CENTRO)
- **Responsive** con collasso a singola colonna su mobile

### Esempi Esistenti
- `nvl5_gram_p001.html.erb` - Copertina (pagina 1)
- `nvl5_gram_p002.html.erb` - Indice (pagine 2 e 3)
- `_nvl5_gram_index_page_2.html.erb` - Contenuto pagina sinistra (2)
- `_nvl5_gram_index_page_3.html.erb` - Contenuto pagina destra (3)

---

## PROMPT RAPIDO

```
Crea l'indice a due pagine per il libro [NOME_LIBRO] con questa struttura:

PAGINA 2:
- SEZIONE 1 (colore)
  - Pagina speciale (icona)
  - Sottosezione (badge)
    - Argomento 1 -> pagina X
    - Argomento 2 -> pagina Y
    - VERIFICA -> pagina Z
- SEZIONE 2 (colore)
  ...

PAGINA 3:
- SEZIONE 2 (continua)
  ...
- SEZIONE 3 (colore)
  ...
```

### Esempio:
```
Crea l'indice a due pagine per "Nuovi Volentieri 5 - Grammatica"

PAGINA 2:
- ORTOGRAFIA (rosa)
  - IN BIBLIOTECA (💬)
  - IMPARARE TUTTI
    - Riconoscere le difficoltà ortografiche -> 6
    - Scrivere bene i testi -> 7
    - VERIFICA: L'ortografia -> 20
- LESSICO (blu)
  - AL SUPERMERCATO (💬)
    - L'origine della lingua italiana -> 24
    ...

PAGINA 3:
- MORFOLOGIA (verde, continua)
  - VERIFICA: Aggettivi e pronomi -> 64
  ...
```

---

## STRUTTURA TECNICA

### 1. Pagina Principale (es. nvl5_gram_p002.html.erb)

```erb
<% content_for :left_page_content do %>
  <%= render 'exercises/nvl5_gram_index_page_2' %>
<% end %>

<% content_for :right_page_content do %>
  <%= render 'exercises/nvl5_gram_index_page_3' %>
<% end %>

<div class="max-w-[1800px] mx-auto p-2 lg:p-8 bg-gradient-to-b from-yellow-50 via-white to-yellow-50">

  <!-- Two-page horizontal layout like an open book -->
  <div class="grid lg:grid-cols-2 gap-3 lg:gap-8">

    <!-- LEFT PAGE - Page 2 -->
    <div class="bg-white rounded-xl shadow-2xl p-3 lg:p-8 relative border-4 border-blue-200">
      <!-- Page number top right -->
      <div class="absolute top-2 right-2 lg:top-4 lg:right-4 bg-blue-600 text-white rounded-full w-8 h-8 lg:w-10 lg:h-10 flex items-center justify-center font-bold text-base lg:text-xl shadow-lg">
        2
      </div>

      <%= content_for(:left_page_content) %>
    </div>

    <!-- RIGHT PAGE - Page 3 -->
    <div class="bg-white rounded-xl shadow-2xl p-3 lg:p-8 relative border-4 border-blue-200">
      <!-- Page number top right -->
      <div class="absolute top-2 right-2 lg:top-4 lg:right-4 bg-blue-600 text-white rounded-full w-8 h-8 lg:w-10 lg:h-10 flex items-center justify-center font-bold text-base lg:text-xl shadow-lg">
        3
      </div>

      <%= content_for(:right_page_content) %>
    </div>

  </div>

  <%= render 'shared/exercise_controls', color: 'blue', show_exercise_buttons: false %>
</div>
```

**Caratteristiche**:
- Container `max-w-[1800px]` per layout largo
- Grid `lg:grid-cols-2` che diventa singola colonna su mobile
- Background gradient `from-yellow-50 via-white to-yellow-50`
- Pagine con shadow, border e border-radius
- Numero di pagina in alto a destra (absolute positioning)
- Content blocks popolati dai partial

---

## ELEMENTI DI CONTENUTO

### 2. Header INDICE

```erb
<!-- Header INDICE -->
<div class="relative mb-4 lg:mb-8">
  <div class="bg-blue-600 text-white rounded-full px-3 py-1 lg:px-6 lg:py-3 inline-block">
    <h1 class="text-2xl lg:text-4xl font-bold">INDICE</h1>
  </div>
</div>
```

### 3. Sezione Standard con Badge Rotondo

```erb
<!-- ORTOGRAFIA Section -->
<div class="mb-4 lg:mb-8">
  <div class="bg-pink-600 text-white rounded-full px-3 py-1 lg:px-6 lg:py-3 inline-block mb-3 lg:mb-4">
    <h2 class="text-lg lg:text-2xl font-bold">ORTOGRAFIA</h2>
  </div>

  <!-- contenuto qui -->
</div>
```

**Colori sezioni**:
- `bg-pink-600` - ORTOGRAFIA
- `bg-blue-600` - LESSICO
- `bg-green-600` - MORFOLOGIA
- `bg-orange-500` - SINTASSI

### 4. Pagina Speciale con Icona (es. PAROLE AL CENTRO)

```erb
<!-- IN BIBLIOTECA -->
<div class="ml-2 lg:ml-4 mb-3 lg:mb-4">
  <div class="flex items-center gap-2 mb-2">
    <span class="text-2xl lg:text-3xl">💬</span>
    <%= link_to "IN BIBLIOTECA", "nvl5_gram_p004", class: "flex-1 text-blue-600 font-bold text-base lg:text-lg hover:text-blue-800" %>
    <span class="text-gray-700 font-medium text-sm">4</span>
  </div>
</div>
```

**Icone comuni**:
- 💬 - PAROLE AL CENTRO
- 👂 - IMPARARE TUTTI (può essere usato)
- Altre emoji contestuali

### 5. Badge Speciale (es. IMPARARE TUTTI)

```erb
<!-- IMPARARE TUTTI -->
<div class="ml-2 lg:ml-4 mb-2">
  <div class="flex items-center gap-2">
    <span class="text-xl lg:text-2xl">👂</span>
    <span class="bg-yellow-400 text-blue-800 px-2 py-0.5 lg:px-3 lg:py-1 rounded font-bold text-xs lg:text-sm">IMPARARE TUTTI</span>
    <%= link_to "6", "nvl5_gram_p006", class: "ml-auto text-gray-700 hover:text-blue-600 font-medium text-sm" %>
  </div>
</div>
```

**Badge disponibili**:
- `bg-yellow-400 text-blue-800` - IMPARARE TUTTI
- Altri badge personalizzati secondo le esigenze

### 6. Lista Argomenti

```erb
<div class="ml-4 lg:ml-8 space-y-1 text-xs lg:text-sm">
  <div class="flex justify-between items-center hover:bg-gray-50 px-2 py-1 rounded">
    <span class="text-orange-500">●</span>
    <%= link_to "Riconoscere le difficoltà ortografiche", "nvl5_gram_p006", class: "flex-1 ml-2 text-blue-700 font-medium" %>
    <span class="text-gray-700">6</span>
  </div>
  <div class="flex justify-between items-center hover:bg-gray-50 px-2 py-1 rounded">
    <span class="text-orange-500">●</span>
    <%= link_to "Scrivere bene i testi", "nvl5_gram_p007", class: "flex-1 ml-2" %>
    <span class="text-gray-700">7</span>
  </div>
  <!-- ... -->
</div>
```

**Caratteristiche**:
- Bullet arancione `text-orange-500 ●`
- Hover effect `hover:bg-gray-50`
- Link con `flex-1 ml-2`
- Numero pagina allineato a destra

### 7. Verifica in Lista

```erb
<div class="flex justify-between items-center hover:bg-gray-50 px-2 py-1 rounded">
  <span class="bg-pink-600 text-white px-2 py-0.5 rounded text-xs font-bold">VERIFICA</span>
  <%= link_to "L'ortografia", "nvl5_gram_p020", class: "flex-1 ml-2" %>
  <span class="text-gray-700">20</span>
</div>
```

**Colori badge VERIFICA** (deve matchare il colore della sezione):
- `bg-pink-600` - ORTOGRAFIA
- `bg-blue-600` - LESSICO
- `bg-green-600` - MORFOLOGIA
- `bg-orange-500` - SINTASSI

---

## STILI SPECIALI PER SEZIONI

### 8. Sezione con Box e Border (es. ANALISI GRAMMATICALE)

```erb
<!-- ANALISI GRAMMATICALE Section -->
<div class="mb-4 lg:mb-8">
  <div class="border-4 border-blue-600 rounded-3xl p-4 lg:p-6 bg-blue-50">
    <h2 class="text-lg lg:text-2xl font-bold text-blue-700 mb-3 lg:mb-4">ANALISI GRAMMATICALE</h2>
    <div class="space-y-1 text-xs lg:text-sm">
      <div class="flex justify-between items-center hover:bg-white px-2 py-1 rounded">
        <span class="text-orange-500">●</span>
        <%= link_to "Analizzare il nome e l'articolo", "nvl5_gram_p096", class: "flex-1 ml-2" %>
        <span class="text-gray-700">96</span>
      </div>
      <!-- ... -->
    </div>
  </div>
</div>
```

**Varianti**:
- `bg-blue-50` - background celeste chiaro
- `bg-white` - background bianco
- `bg-blue-100` - background celeste più scuro
- `hover:bg-white` o `hover:bg-gray-50` a seconda del background

### 9. Sezione con Box Arrotondato (es. IL MIO QUADERNO)

```erb
<!-- IL MIO QUADERNO Section -->
<div class="mb-4 lg:mb-8">
  <div class="bg-blue-100 rounded-2xl p-4 lg:p-6">
    <h2 class="text-lg lg:text-2xl font-bold text-blue-700 mb-3 lg:mb-4">IL MIO QUADERNO</h2>
    <div class="space-y-1 text-xs lg:text-sm">
      <div class="flex justify-between items-center hover:bg-white px-2 py-1 rounded">
        <span class="text-orange-500">●</span>
        <%= link_to "Tavole dei verbi", "nvl5_gram_p126", class: "flex-1 ml-2" %>
        <span class="text-gray-700">126</span>
      </div>
      <!-- ... -->
    </div>
  </div>
</div>
```

### 10. Box Informativo (es. PAROLE al centro)

```erb
<!-- PAROLE al centro Box -->
<div class="border-4 border-pink-500 rounded-3xl p-4 lg:p-6 bg-white">
  <div class="flex items-center gap-2 lg:gap-3 mb-2 lg:mb-3">
    <h2 class="text-lg lg:text-2xl font-bold text-blue-600">PAROLE</h2>
    <span class="text-2xl lg:text-3xl">💬</span>
    <span class="text-blue-500 italic text-base lg:text-lg">al centro</span>
  </div>
  <p class="text-sm lg:text-base text-gray-700 leading-relaxed">
    Il nuovo progetto per accompagnare bambine e bambini nell'apprendimento della lingua italiana e per valorizzare tutte le lingue della classe.
  </p>
</div>
```

### 11. Sezione Multi-Pagina (es. ANALISI LOGICA)

```erb
<!-- ANALISI LOGICA GRAMMATICA VALENZIALE Section -->
<div class="mb-4 lg:mb-8">
  <div class="border-4 border-blue-600 rounded-3xl p-3 lg:p-4 bg-white">
    <div class="flex justify-between items-center">
      <h2 class="text-base lg:text-xl font-bold text-blue-700">ANALISI LOGICA<br>GRAMMATICA VALENZIALE</h2>
      <div class="text-right">
        <div class="text-gray-700 font-medium text-sm">118</div>
        <div class="text-gray-700 font-medium text-sm">120</div>
      </div>
    </div>
  </div>

  <div class="ml-4 lg:ml-8 mt-2 space-y-1 text-xs lg:text-sm">
    <!-- argomenti -->
  </div>
</div>
```

---

## CONTINUAZIONE SEZIONE SU PAGINA SUCCESSIVA

Quando una sezione inizia su pagina 2 e continua su pagina 3:

**Pagina 2** (_nvl5_gram_index_page_2.html.erb):
```erb
<!-- MORFOLOGIA Section -->
<div class="mb-3 lg:mb-6">
  <div class="bg-green-600 text-white rounded-full px-3 py-1 lg:px-6 lg:py-3 inline-block mb-3 lg:mb-4">
    <h2 class="text-lg lg:text-2xl font-bold">MORFOLOGIA</h2>
  </div>

  <!-- IN PALESTRA -->
  <div class="ml-2 lg:ml-4 mb-2">
    <div class="flex items-center gap-2">
      <span class="text-2xl lg:text-3xl">💬</span>
      <%= link_to "IN PALESTRA", "nvl5_gram_p040", class: "flex-1 text-green-700 font-bold text-base lg:text-lg hover:text-green-900" %>
      <span class="text-gray-700 font-medium text-sm">40</span>
    </div>
  </div>

  <div class="ml-4 lg:ml-8 space-y-1 text-xs lg:text-sm">
    <!-- primi argomenti -->
  </div>
</div>
```

**Pagina 3** (_nvl5_gram_index_page_3.html.erb):
```erb
<!-- MORFOLOGIA Section (continued) -->
<div class="mb-4 lg:mb-8 mt-8 lg:mt-16">
  <div class="ml-4 lg:ml-8 space-y-1 text-xs lg:text-sm">
    <!-- continua argomenti -->
  </div>
</div>
```

**NOTA**: Senza badge header, solo il contenuto continua.

---

## RESPONSIVE DESIGN

### Breakpoints e Classi
- **mobile**: < 1024px (default, no prefix)
- **lg**: ≥ 1024px (desktop)

### Font Size
```
text-xs lg:text-sm      - testo piccolo (liste)
text-sm lg:text-base    - testo medio
text-base lg:text-lg    - testo grande (link principali)
text-lg lg:text-2xl     - titoli sezioni
text-2xl lg:text-4xl    - header INDICE
```

### Padding e Margin
```
p-2 lg:p-8              - container principale
p-3 lg:p-8              - pagine libro
px-3 py-1 lg:px-6 lg:py-3  - badge sezioni
p-4 lg:p-6              - box con border
mb-3 lg:mb-4            - margin bottom medio
mb-4 lg:mb-8            - margin bottom grande
ml-2 lg:ml-4            - indentazione livello 1
ml-4 lg:ml-8            - indentazione livello 2
```

### Gap
```
gap-2 lg:gap-3          - gap piccolo
gap-3 lg:gap-8          - gap grande (grid pagine)
```

### Elementi
```
w-8 h-8 lg:w-10 lg:h-10     - numero pagina circolare
text-2xl lg:text-3xl        - emoji
rounded-2xl / rounded-3xl   - border radius box
border-4                    - border spesso per box speciali
```

---

## COLORI E TEMI

### Sezioni Principali
```css
ORTOGRAFIA:    bg-pink-600 / text-pink-600
LESSICO:       bg-blue-600 / text-blue-600
MORFOLOGIA:    bg-green-600 / text-green-700
SINTASSI:      bg-orange-500 / text-orange-600
```

### Badge e Accenti
```css
VERIFICA:      bg-[colore-sezione] text-white
IMPARARE TUTTI: bg-yellow-400 text-blue-800
Bullet:        text-orange-500
Link default:  text-blue-700
Link hover:    hover:text-blue-800
Numero pagina: text-gray-700
```

### Background
```css
Container:     bg-gradient-to-b from-yellow-50 via-white to-yellow-50
Pagine:        bg-white
Border pagine: border-blue-200
Hover lista:   hover:bg-gray-50 (su bg-white)
               hover:bg-white (su bg-blue-50 o bg-blue-100)
```

---

## WORKFLOW CREAZIONE INDICE

### Step 1: Analizza Struttura del Libro
1. Identifica le **sezioni principali** (es. ORTOGRAFIA, LESSICO, etc.)
2. Identifica i **colori** per ogni sezione
3. Trova le **pagine speciali** (PAROLE AL CENTRO, etc.)
4. Identifica i **badge speciali** (IMPARARE TUTTI, etc.)
5. Conta gli **argomenti** e le **verifiche**
6. Decidi dove **spezzare** tra pagina 2 e pagina 3

### Step 2: Crea Copertina (p001)
```erb
<div class="max-w-4xl mx-auto p-8" data-controller="exercise-checker">
  <%#= render 'shared/page_header', pagina: @pagina %>

  <!-- Copertina del libro - Immagine originale -->
  <div class="flex items-center justify-center bg-white rounded-lg shadow-xl p-4">
    <%= image_tag "LIBRO/p001/page.png", class: "w-full h-auto rounded-lg", alt: "Copertina TITOLO" %>
  </div>

  <!-- Exercise Controls -->
  <%= render 'shared/exercise_controls', color: @pagina.base_color || 'orange', show_exercise_buttons: false %>
</div>
```

### Step 3: Crea Layout Due Pagine (p002)
Usa il template in **STRUTTURA TECNICA** sezione 1.

### Step 4: Crea Partial Pagina 2
File: `app/views/exercises/_LIBRO_index_page_2.html.erb`

1. Header INDICE
2. Prima sezione completa o parziale
3. Seconda sezione (eventualmente parziale)

### Step 5: Crea Partial Pagina 3
File: `app/views/exercises/_LIBRO_index_page_3.html.erb`

1. Eventuale continuazione sezione precedente (senza header)
2. Sezioni successive
3. Box speciali (ANALISI GRAMMATICALE, IL MIO QUADERNO, PAROLE al centro)

### Step 6: Aggiorna Seed
```ruby
# Pagina 1 - Copertina
Pagina.find_or_create_by!(slug: "nvl5_gram_p001") do |p|
  p.numero = 1
  p.volume = volume_nvl5_gram
  p.titolo = "Copertina"
  p.sottotitolo = ""
  p.base_color = "orange"
  p.esercizi_data = {}
end

# Pagina 2-3 - Indice
Pagina.find_or_create_by!(slug: "nvl5_gram_p002") do |p|
  p.numero = 2
  p.volume = volume_nvl5_gram
  p.titolo = "Indice"
  p.sottotitolo = ""
  p.base_color = "blue"
  p.esercizi_data = {}
end
```

### Step 7: Rigenera Database
```bash
rails db:reset
```

### Step 8: Verifica Responsive
1. Testa su desktop (layout a due colonne)
2. Testa su mobile (layout a singola colonna)
3. Verifica tutti i link funzionino
4. Controlla hover effects

---

## TEMPLATE COMPLETO

### Pagina Principale (p002.html.erb)
```erb
<% content_for :left_page_content do %>
  <%= render 'exercises/LIBRO_index_page_2' %>
<% end %>

<% content_for :right_page_content do %>
  <%= render 'exercises/LIBRO_index_page_3' %>
<% end %>

<div class="max-w-[1800px] mx-auto p-2 lg:p-8 bg-gradient-to-b from-yellow-50 via-white to-yellow-50">

  <!-- Two-page horizontal layout like an open book -->
  <div class="grid lg:grid-cols-2 gap-3 lg:gap-8">

    <!-- LEFT PAGE - Page 2 -->
    <div class="bg-white rounded-xl shadow-2xl p-3 lg:p-8 relative border-4 border-blue-200">
      <!-- Page number top right -->
      <div class="absolute top-2 right-2 lg:top-4 lg:right-4 bg-blue-600 text-white rounded-full w-8 h-8 lg:w-10 lg:h-10 flex items-center justify-center font-bold text-base lg:text-xl shadow-lg">
        2
      </div>

      <%= content_for(:left_page_content) %>
    </div>

    <!-- RIGHT PAGE - Page 3 -->
    <div class="bg-white rounded-xl shadow-2xl p-3 lg:p-8 relative border-4 border-blue-200">
      <!-- Page number top right -->
      <div class="absolute top-2 right-2 lg:top-4 lg:right-4 bg-blue-600 text-white rounded-full w-8 h-8 lg:w-10 lg:h-10 flex items-center justify-center font-bold text-base lg:text-xl shadow-lg">
        3
      </div>

      <%= content_for(:right_page_content) %>
    </div>

  </div>

  <%= render 'shared/exercise_controls', color: 'blue', show_exercise_buttons: false %>
</div>
```

### Partial Pagina 2 (_LIBRO_index_page_2.html.erb)
```erb
<!-- Header INDICE -->
<div class="relative mb-4 lg:mb-8">
  <div class="bg-blue-600 text-white rounded-full px-3 py-1 lg:px-6 lg:py-3 inline-block">
    <h1 class="text-2xl lg:text-4xl font-bold">INDICE</h1>
  </div>
</div>

<!-- SEZIONE 1 -->
<div class="mb-4 lg:mb-8">
  <div class="bg-COLORE-600 text-white rounded-full px-3 py-1 lg:px-6 lg:py-3 inline-block mb-3 lg:mb-4">
    <h2 class="text-lg lg:text-2xl font-bold">NOME SEZIONE</h2>
  </div>

  <!-- Pagina speciale (opzionale) -->
  <div class="ml-2 lg:ml-4 mb-3 lg:mb-4">
    <div class="flex items-center gap-2 mb-2">
      <span class="text-2xl lg:text-3xl">💬</span>
      <%= link_to "TITOLO PAGINA", "libro_pXXX", class: "flex-1 text-COLORE-600 font-bold text-base lg:text-lg hover:text-COLORE-800" %>
      <span class="text-gray-700 font-medium text-sm">XX</span>
    </div>
  </div>

  <!-- Lista argomenti -->
  <div class="ml-4 lg:ml-8 space-y-1 text-xs lg:text-sm">
    <div class="flex justify-between items-center hover:bg-gray-50 px-2 py-1 rounded">
      <span class="text-orange-500">●</span>
      <%= link_to "Argomento 1", "libro_pXXX", class: "flex-1 ml-2" %>
      <span class="text-gray-700">XX</span>
    </div>
    <div class="flex justify-between items-center hover:bg-gray-50 px-2 py-1 rounded">
      <span class="bg-COLORE-600 text-white px-2 py-0.5 rounded text-xs font-bold">VERIFICA</span>
      <%= link_to "Titolo verifica", "libro_pXXX", class: "flex-1 ml-2" %>
      <span class="text-gray-700">XX</span>
    </div>
  </div>
</div>

<!-- SEZIONE 2 -->
<!-- ... -->
```

### Partial Pagina 3 (_LIBRO_index_page_3.html.erb)
```erb
<!-- SEZIONE 1 (continued, se necessario) -->
<div class="mb-4 lg:mb-8 mt-8 lg:mt-16">
  <div class="ml-4 lg:ml-8 space-y-1 text-xs lg:text-sm">
    <!-- continua argomenti -->
  </div>
</div>

<!-- NUOVE SEZIONI -->
<!-- ... -->
```

---

## ESEMPI REALI

### Esempio 1: Nuovi Volentieri 5 Grammatica
```
Volume: Nuovi Volentieri 5 Grammatica
Pagina 1: Copertina
Pagine 2-3: Indice

Sezioni:
- ORTOGRAFIA (rosa) - p004-p020
  - IN BIBLIOTECA (💬)
  - IMPARARE TUTTI (badge giallo)
- LESSICO (blu) - p022-p038
  - AL SUPERMERCATO (💬)
- MORFOLOGIA (verde) - p040-p094
  - IN PALESTRA (💬)
  - ANALISI GRAMMATICALE (box border)
- SINTASSI (arancione) - p100-p116
  - AL NEGOZIO DI ABBIGLIAMENTO (💬)
  - ANALISI LOGICA (box border)
- IL MIO QUADERNO (box blu) - p126-p190
- PAROLE al centro (box border rosa)
```

**File**:
- `nvl5_gram_p001.html.erb` - Copertina
- `nvl5_gram_p002.html.erb` - Layout due pagine
- `_nvl5_gram_index_page_2.html.erb` - Contenuto pagina 2
- `_nvl5_gram_index_page_3.html.erb` - Contenuto pagina 3

---

## TROUBLESHOOTING

### I link non funzionano
**Verifica**:
- Slug corretto nel `link_to` (es. `"nvl5_gram_p006"`)
- Pagina esistente nel seed
- Route configurata correttamente

### Layout non responsive
**Verifica**:
- Classi responsive `lg:` applicate
- Grid `lg:grid-cols-2` sul container
- Font size responsive `text-xs lg:text-sm`

### Pagine non allineate
**Verifica**:
- Padding uguale su entrambe le pagine
- Numero di pagina con `absolute` positioning
- `top-2 right-2 lg:top-4 lg:right-4`

### Sezioni sbilenche tra pagina 2 e 3
**Soluzione**:
- Bilancia meglio il contenuto
- Sposta alcune voci da pagina 2 a pagina 3
- Verifica margin/padding consistenti

---

## CHECKLIST FINALE

Prima di considerare l'indice completo:

- [ ] Copertina (p001) creata con immagine corretta
- [ ] Layout due pagine (p002) configurato
- [ ] Partial pagina 2 con header INDICE
- [ ] Partial pagina 3 con contenuto
- [ ] Tutte le sezioni tematiche presenti
- [ ] Colori sezioni corretti e consistenti
- [ ] Pagine speciali con icone (💬)
- [ ] Badge speciali (IMPARARE TUTTI, VERIFICA)
- [ ] Lista argomenti completa con numeri pagina
- [ ] Link a tutte le pagine funzionanti
- [ ] Responsive testato (desktop e mobile)
- [ ] Hover effects verificati
- [ ] Seed aggiornato per p001 e p002
- [ ] Database rigenerato
- [ ] Box speciali formattati correttamente (ANALISI GRAMMATICALE, IL MIO QUADERNO, PAROLE al centro)

---

## COSA MI SERVE DA TE

**MINIMO INDISPENSABILE:**
1. ✅ Nome del libro/volume
2. ✅ Elenco completo delle sezioni con colori
3. ✅ Lista di tutte le pagine con titoli e numeri
4. ✅ Identificazione pagine speciali (PAROLE AL CENTRO, etc.)
5. ✅ Identificazione verifiche

**OPZIONALE:**
6. ⚠️ Badge speciali da inserire
7. ⚠️ Box informativi finali
8. ⚠️ Note su come dividere contenuto tra pagina 2 e 3

**Il resto lo faccio io! 🚀**
