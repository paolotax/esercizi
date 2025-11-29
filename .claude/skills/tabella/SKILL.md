# Skill: Tabella Standard

Trasforma qualsiasi tabella HTML nel layout standard del progetto.

## Layout Base

```html
<div class="overflow-x-auto">
  <table class="w-full border-separate border-spacing-0 border-2 border-cyan-400 rounded-lg overflow-hidden">
    <thead>
      <tr>
        <th class="border border-cyan-400 px-4 py-1">Intestazione 1</th>
        <th class="border border-cyan-400 px-4 py-1">Intestazione 2</th>
        <!-- altre colonne -->
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="border border-cyan-400 px-4 py-1">Cella 1</td>
        <td class="border border-cyan-400 px-4 py-1">Cella 2</td>
      </tr>
      <!-- altre righe -->
    </tbody>
  </table>
</div>
```

## Classi Chiave

- **Wrapper**: `overflow-x-auto` (scroll orizzontale su mobile)
- **Table**: `w-full border-separate border-spacing-0 border-2 border-cyan-400 rounded-lg overflow-hidden`
- **Celle (th/td)**: `border border-cyan-400 px-4 py-1`
- **Contenuto centrato**: aggiungi `text-center` alla cella

## Con Checkbox

Per celle con checkbox verificabili:

```html
<td class="border border-cyan-400 px-4 py-1 text-center">
  <input type="checkbox" class="w-5 h-5 accent-red-500 cursor-pointer"
         data-correct-answer="true">
</td>
```

## Istruzioni

1. Analizza la tabella esistente
2. Applica le classi standard a table, th, td
3. Wrappa in `overflow-x-auto` se non presente
4. Mantieni il contenuto originale delle celle

## Variante: Tabella con Bordi Esterni e Angoli Arrotondati

Per tabelle con perimetro evidenziato e angoli smussati (come tabelle posizionali decimali).

**IMPORTANTE**: Per evitare bordi doppi, usa solo `border-r` e `border-b` sulle celle interne. I bordi esterni (`border-t-2`, `border-l-2`, `border-r-2`, `border-b-2`) vanno applicati solo sul perimetro della tabella.

### Pattern Anti-Bordi-Doppi

Con `border-separate border-spacing-0`, ogni cella deve specificare solo i bordi necessari:
- **Celle interne**: `border-r border-b` (solo destra e basso)
- **Bordo esterno sinistro**: aggiungi `border-l-2`
- **Bordo esterno destro**: sostituisci `border-r` con `border-r-2`
- **Bordo esterno superiore**: aggiungi `border-t-2`
- **Bordo esterno inferiore**: sostituisci `border-b` con `border-b-2`

### Layout

```html
<table class="mx-auto border-separate border-spacing-0 text-center text-sm">
  <thead>
    <tr class="font-bold">
      <th class="px-2 py-1"></th> <!-- cella vuota senza bordi -->
      <th class="border-t-2 border-l-2 border-r border-b border-cyan-400 px-2 py-1 rounded-tl-lg">km</th>
      <th class="border-t-2 border-r border-b border-cyan-400 px-2 py-1">hm</th>
      <th class="border-t-2 border-r border-b border-cyan-400 px-2 py-1">dam</th>
      <th class="border-t-2 border-r border-b border-cyan-400 px-2 py-1">m</th>
      <th class="border-t-2 border-r border-b border-cyan-400 px-2 py-1">dm</th>
      <th class="border-t-2 border-r border-b border-cyan-400 px-2 py-1">cm</th>
      <th class="border-t-2 border-r-2 border-b border-cyan-400 px-2 py-1 rounded-tr-lg">mm</th>
      <th class="px-2 py-1"></th> <!-- cella vuota senza bordi -->
    </tr>
  </thead>
  <tbody>
    <!-- Prima riga body (ha border-t per separazione da header) -->
    <tr>
      <td class="border-t-2 border-l-2 border-r border-b border-cyan-400 px-3 py-1 rounded-tl-lg text-left">164 m</td>
      <td class="border-t border-l-2 border-r border-b border-cyan-400 px-2 py-1"></td>
      <td class="border-t border-r border-b border-cyan-400 px-2 py-1">1</td>
      <td class="border-t border-r border-b border-cyan-400 px-2 py-1">6</td>
      <td class="border-t border-r border-b border-cyan-400 px-2 py-1">4</td>
      <td class="border-t border-r border-b border-cyan-400 px-2 py-1"></td>
      <td class="border-t border-r border-b border-cyan-400 px-2 py-1"></td>
      <td class="border-t border-r-2 border-b border-cyan-400 px-2 py-1"></td>
      <td class="border-t-2 border-r-2 border-b border-cyan-400 px-3 py-1 rounded-tr-lg text-left">= 1640 dm</td>
    </tr>
    <!-- Righe intermedie (no border-t, il border-b della riga sopra fa da separatore) -->
    <tr>
      <td class="border-l-2 border-r border-b border-cyan-400 px-3 py-1 text-left">2300 cm</td>
      <td class="border-l-2 border-r border-b border-cyan-400 px-2 py-1">...</td>
      <td class="border-r border-b border-cyan-400 px-2 py-1">...</td>
      <!-- ... celle interne ... -->
      <td class="border-r-2 border-b border-cyan-400 px-2 py-1">...</td>
      <td class="border-r-2 border-b border-cyan-400 px-3 py-1 text-left">= ... m</td>
    </tr>
    <!-- Ultima riga (border-b-2 per chiudere il perimetro) -->
    <tr>
      <td class="border-l-2 border-r border-b-2 border-cyan-400 px-3 py-1 rounded-bl-lg text-left">7 dam</td>
      <td class="border-l-2 border-r border-b-2 border-cyan-400 px-2 py-1">...</td>
      <td class="border-r border-b-2 border-cyan-400 px-2 py-1">...</td>
      <!-- ... celle interne ... -->
      <td class="border-r-2 border-b-2 border-cyan-400 px-2 py-1">...</td>
      <td class="border-r-2 border-b-2 border-cyan-400 px-3 py-1 rounded-br-lg text-left">= ... cm</td>
    </tr>
  </tbody>
</table>
```

### Classi per Posizione

| Posizione | Classi Border |
|-----------|---------------|
| **Header, prima cella** | `border-t-2 border-l-2 border-r border-b rounded-tl-lg` |
| **Header, celle centrali** | `border-t-2 border-r border-b` |
| **Header, ultima cella** | `border-t-2 border-r-2 border-b rounded-tr-lg` |
| **Body, celle sinistre** | `border-l-2 border-r border-b` |
| **Body, celle centrali** | `border-r border-b` |
| **Body, celle destre** | `border-r-2 border-b` |
| **Ultima riga, prima cella** | `border-l-2 border-r border-b-2 rounded-bl-lg` |
| **Ultima riga, celle centrali** | `border-r border-b-2` |
| **Ultima riga, ultima cella** | `border-r-2 border-b-2 rounded-br-lg` |

### Colonna Virgola (opzionale)

```html
<td class="border-r border-b border-cyan-400 px-0 py-1 w-0 font-bold text-3xl text-red-500">
  <span class="inline-block translate-y-2">,</span>
</td>
```
- `w-0 px-0` per colonna stretta
- `translate-y-2` per centrare verticalmente la virgola
