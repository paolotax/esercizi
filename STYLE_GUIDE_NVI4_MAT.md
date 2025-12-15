# Guida Stili NVI4_MAT - Dark Mode Completo

## Box Container Principali

| Pattern | Uso |
|---------|-----|
| `p-4 md:p-6 bg-custom-blue dark:bg-cyan-900 rounded-2xl` | Box Regola/Teoria (celeste) |
| `p-3 bg-white dark:bg-gray-800 border-3 border-dashed border-base_color-400 dark:border-base_color-500 w-fit` | Box Note/Suggerimenti/Ricordati |
| `p-4 md:p-6 bg-orange-100 dark:bg-orange-900/30 rounded-2xl` | Box Esercizi |
| `p-4 md:p-6 bg-gradient-to-b from-blue-100 to-purple-50 dark:from-blue-900/30 dark:to-purple-900/30 rounded-2xl` | Box Gradiente |
| `p-4 bg-pink-light dark:bg-pink-900/40 rounded-2xl` | Box rosa |
| `p-4 bg-pink-light dark:bg-pink-900/40 rounded-2xl w-fit` | Box rosa compatto |
| `bg-white dark:bg-gray-800 rounded-3xl border-4 border-blue-800 dark:border-blue-600 p-4` | Box bianco bordo blu |

## Tabelle

| Pattern | Uso |
|---------|-----|
| `border-2 border-cyan-400 dark:border-cyan-600` | Bordo tabella standard |
| `bg-white dark:bg-gray-800 overflow-hidden border-2 border-cyan-400 dark:border-cyan-600` | Contenitore tabella |

## Celle Tabella

| Pattern | Uso |
|---------|-----|
| `p-2 border-2 border-cyan-400 dark:border-cyan-600` | Cella standard |
| `p-2 border-2 border-cyan-400 dark:border-cyan-600 bg-white dark:bg-gray-700 text-center` | Cella con sfondo |
| `text-cyan-600 dark:text-cyan-400 font-bold` | Numeri evidenziati |
| `text-red-600/blue-600/green-600/purple-600 font-bold` | Cifre colorate (usare dark:text-*-400) |

## Header Tabelle

| Pattern | Uso |
|---------|-----|
| `bg-custom-blue-light dark:bg-cyan-900/50` | Header tabelle |

## Box Interni

| Pattern | Uso |
|---------|-----|
| `bg-white dark:bg-gray-800 p-4 rounded-lg` | Box contenuto interno |
| `bg-white dark:bg-gray-800 rounded-2xl p-4 border-3 border-base_color-300 dark:border-base_color-600` | Card con bordo |

## Elementi Interattivi

| Pattern | Uso |
|---------|-----|
| `px-2 py-1 bg-transparent border-2 border-cyan-400 dark:border-cyan-600 rounded cursor-grab dark:text-gray-200` | Elementi draggable |

## Divider

| Pattern | Uso |
|---------|-----|
| `md:divide-x-2 md:divide-orange-300 dark:divide-orange-700` | Divider tra esercizi |
| `divide-y-2 md:divide-y-0 md:divide-x-2 divide-cyan-300 dark:divide-cyan-700` | Divider responsive |

## Testi

| Pattern | Uso |
|---------|-----|
| `text-gray-700 dark:text-gray-200` | Testo principale |
| `text-gray-600 dark:text-gray-300` | Testo secondario |
| `text-gray-500 dark:text-gray-400` | Testo terziario |

## Input

| Pattern | Uso |
|---------|-----|
| `border-b-2 border-dotted border-gray-400 dark:border-gray-500 bg-transparent dark:text-white` | Input standard |

## Immagini (con sfondo bianco)

| Pattern | Uso |
|---------|-----|
| `dark:bg-white dark:rounded-lg dark:p-2` | Immagini con sfondo bianco in dark mode |

## Riepilogo Colori Dark Mode

| Colore Light | Colore Dark | Uso |
|--------------|-------------|-----|
| `bg-custom-blue` | `dark:bg-cyan-900` | Box Ricorda |
| `bg-custom-blue-light` | `dark:bg-cyan-900/50` | Header tabelle |
| `bg-orange-100` | `dark:bg-orange-900/30` | Box Esercizi |
| `bg-pink-light` | `dark:bg-pink-900/40` | Box rosa (#EFD9E9) |
| `border-cyan-400` | `dark:border-cyan-600` | Bordi tabelle/celle |
| `border-blue-800` | `dark:border-blue-600` | Bordi box teoria |
| `border-gray-200` | `dark:border-gray-600` | Bordi radio/checkbox |
| `border-gray-300` | `dark:border-gray-600` | Bordi celle/sequence |
| `text-cyan-600` | `dark:text-cyan-400` | Testo evidenziato |
| `text-gray-700` | `dark:text-gray-200` | Testo principale |
| `text-gray-800` | `dark:text-gray-200` | Testo bold |
| `text-gray-600` | `dark:text-gray-300` | Testo secondario |
| `text-gray-500` | `dark:text-gray-400` | Testo terziario |
| `bg-white` | `dark:bg-gray-800` | Box bianchi |
| `bg-white` | `dark:bg-gray-700` | Celle tabella/sequence |
| `bg-white` | `dark:bg-gray-900` | Sfondo pagina |
| `hover:bg-gray-50` | `dark:hover:bg-gray-700` | Hover elementi |

## Box Note/Suggerimenti/Ricordati (IMPORTANTE!)

Per note, suggerimenti, promemoria e "Ricordati che...":

```erb
<!-- Box nota standalone -->
<div class="p-3 bg-white dark:bg-gray-800 border-3 border-dashed border-<%= @pagina.base_color %>-400 dark:border-<%= @pagina.base_color %>-500 w-fit">
  <p class="text-gray-700 dark:text-gray-200">
    Ricordati di mettere la virgola al quoziente quando abbassi la prima cifra decimale.
  </p>
</div>
```

**Layout titolo + nota sulla stessa riga:**
```erb
<div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4 mb-4">
  <p class="font-bold text-gray-700 dark:text-gray-200">
    <%= numero_esercizio_badge(1) %>
    Calcola in colonna le divisioni...
  </p>
  <!-- Nota -->
  <div class="p-3 bg-white dark:bg-gray-800 border-3 border-dashed border-<%= @pagina.base_color %>-400 dark:border-<%= @pagina.base_color %>-500 md:w-1/3 shrink-0">
    <p class="text-gray-700 dark:text-gray-200">
      Ricordati di mettere la virgola...
    </p>
  </div>
</div>
```

**Caratteristiche:**
- Sfondo bianco (`bg-white dark:bg-gray-800`)
- Bordo tratteggiato 3px (`border-3 border-dashed`)
- Colore bordo dal `base_color` della pagina
- `w-fit` per adattarsi al contenuto, oppure `md:w-1/3` per larghezza fissa
- `shrink-0` se in layout flex per non comprimersi

**DIFFERENZA da Box Regola/Teoria:**
- **Box Nota/Suggerimenti:** sfondo bianco, bordo tratteggiato → per promemoria, consigli
- **Box Regola/Teoria:** sfondo celeste (`bg-custom-blue`), bordi arrotondati → per regole matematiche importanti

---

## Box AllenaMente (IMPORTANTE!)

```erb
<div class="p-3 bg-white dark:bg-blue-900/40 rounded-2xl border-3 border-blue-400 dark:border-blue-600">
  <p class="font-bold text-gray-800 dark:text-blue-300 mb-2">
    <span class="bg-yellow-400 text-gray-800 px-2 py-1 rounded">AllenaMente!</span>
  </p>
  <p class="text-gray-700 dark:text-gray-200 mb-4">
    Testo della consegna...
  </p>
</div>
```

**Caratteristiche Dark Mode:**
- Sfondo: `dark:bg-blue-900/40` (blu scuro trasparente)
- Testo label: `dark:text-blue-300` (blu chiaro)
- Badge giallo: `text-gray-800` (rimane scuro sul giallo)
- Bordo: `dark:border-blue-600`

## Immagini in Dark Mode

```erb
<%= image_tag "nvi4_mat/pXXX/image.jpg", class: "dark:bg-white dark:rounded-lg dark:p-1" %>
```

Le immagini con sfondo bianco necessitano di un wrapper bianco in dark mode.

## Input in Dark Mode

```erb
<!-- Input dotted standard -->
<input type="text" data-correct-answer="123"
       class="w-20 border-b-2 border-dotted border-gray-400 dark:border-gray-500 text-center font-bold bg-transparent dark:text-white">

<!-- Input box sequenze -->
<input type="text" data-correct-answer="342"
       class="w-16 px-2 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-center font-bold dark:text-white">
```

## Radio Button e Checkbox in Dark Mode

```erb
<label class="flex items-center gap-2 cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700 p-2 rounded border border-gray-200 dark:border-gray-600 text-gray-700 dark:text-gray-200">
  <input type="radio" name="vf1" class="w-5 h-5" data-correct-answer="true">
  <span>Risposta</span>
</label>
```

## Sequenze Numeriche in Dark Mode

```erb
<!-- Numero fisso -->
<span class="px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 font-bold dark:text-white">327</span>

<!-- Freccia -->
<span class="text-<%= @pagina.base_color %>-500">→</span>

<!-- Input -->
<input type="text" data-correct-answer="342" class="w-16 px-2 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-center font-bold dark:text-white">
```

## SVG e Stroke in Dark Mode

Per SVG con stroke che devono cambiare colore:
```erb
<svg class="text-gray-700 dark:text-gray-300" ...>
  <path stroke="currentColor" .../>
</svg>
```

## Partial Scomposizione Calcolo

Il partial `_scomposizione_calcolo.html.erb` usa:
- `text-gray-400` per il segno `+` (visibile in entrambi i modi)
- `stroke="currentColor"` con classe `text-gray-700 dark:text-gray-300` per le frecce SVG
