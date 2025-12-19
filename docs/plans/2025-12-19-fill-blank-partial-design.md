# Fill Blank Partial Design

Data: 2025-12-19

## Obiettivo

Creare un sistema di partial unificato per esercizi "fill in the blank" che gestisca sia completamento testo che operazioni matematiche.

## File da creare

1. `app/views/shared/_fill_item.html.erb` - singolo item
2. `app/views/shared/_fill_list.html.erb` - wrapper lista

## Parametri

### `_fill_item.html.erb`

| Parametro | Tipo | Default | Descrizione |
|-----------|------|---------|-------------|
| `answer` | string | (obbligatorio) | Risposta corretta |
| `prefix` | string | `nil` | Testo prima dell'input |
| `suffix` | string | `nil` | Testo dopo l'input |
| `arrow` | boolean | `false` | Mostra freccia → |
| `equals` | boolean | `false` | Mostra = |
| `unit` | string | `nil` | Unità dopo l'input |
| `width` | string | auto | Larghezza input (es. "w-16") |
| `bullet` | string | `nil` | Simbolo bullet (•, ♦, etc.) |
| `color` | string | `"gray"` | Colore tema (pink, cyan, red...) |
| `inputmode` | string | auto | `"numeric"` o `"text"` (auto-detect) |
| `maxlength` | integer | auto | Lunghezza massima (auto dalla risposta) |
| `segments` | array | `nil` | Array di segmenti misti per input multipli |

### `_fill_list.html.erb`

| Parametro | Tipo | Default | Descrizione |
|-----------|------|---------|-------------|
| `items` | array | (obbligatorio) | Lista degli item |
| `color` | string | `"gray"` | Colore default per tutti |
| `bullet` | string | `nil` | Bullet default per tutti |
| `arrow` | boolean | `false` | Freccia default |
| `equals` | boolean | `false` | Uguale default |
| `width` | string | `nil` | Larghezza default |
| `unit` | string | `nil` | Unità default |
| `container_class` | string | `"space-y-2"` | Classe CSS container |

## Esempi d'uso

### Lista semplice con frasi

```erb
<%= render 'shared/fill_list',
    color: "pink",
    bullet: "•",
    items: [
      { prefix: "Andrò", answer: "a", suffix: "Bologna" },
      { prefix: "Preferisci un panino", answer: "o", suffix: "una mela?" },
      { answer: "Oh", suffix: "! Che meraviglia!" }
    ] %>
```

### Equazioni matematiche

```erb
<%= render 'shared/fill_list',
    color: "cyan",
    equals: true,
    items: [
      { prefix: "5 h", answer: "50", unit: "da" },
      { prefix: "3 da", answer: "30", unit: "u" }
    ] %>
```

### Confronti

```erb
<%= render 'shared/fill_list',
    color: "red",
    items: [
      { prefix: "152", answer: "<", suffix: "528" },
      { prefix: "861", answer: ">", suffix: "618" }
    ] %>
```

### Conversioni con freccia

```erb
<%= render 'shared/fill_list',
    color: "red",
    arrow: true,
    items: [
      { prefix: "856", answer: "ottocentocinquantasei" },
      { prefix: "799", answer: "settecentonovantanove" }
    ] %>
```

### Item singolo

```erb
<%= render 'shared/fill_item',
    prefix: "Quante decine?",
    answer: "5",
    color: "cyan" %>
```

### Input multipli in una riga (segments)

```erb
<%= render 'shared/fill_item',
    bullet: "•",
    color: "pink",
    segments: [
      { answer: "Ah" },
      ", che bellezza! Marta",
      { answer: "ha" },
      "ritrovato la penna."
    ] %>
```

Il parametro `segments` accetta un array misto di:
- Stringhe → testo semplice
- `{ text: "..." }` → testo esplicito
- `{ html: "..." }` → HTML raw (per formattazioni speciali come colori)
- `{ answer: "..." }` → input con risposta corretta
- `{ answer: "...", width: "w-20" }` → input con opzioni

### Esempio con HTML formattato

```erb
<%= render 'shared/fill_item',
    segments: [
      { html: "otto<span class='font-bold text-pink-600'>MILA</span>novecentotrentasette" },
      "si scrive",
      { answer: "8" },
      "937"
    ] %>
```

## Auto-detection

- Se `answer` contiene solo numeri → `inputmode="numeric"`
- Altrimenti → `inputmode="text"`
- `maxlength` = lunghezza risposta (+ margine per testo)

## Note implementative

- Usa sintassi Rails 7+ `locals:` magic comment
- Supporta dark mode con classi `dark:`
- `data-controller="fill-blanks"` applicato solo nel wrapper
- Merge delle opzioni globali con override per item
