# Design: Ricerca FTS5 con Contenuto HTML

**Data:** 2025-12-18

## Obiettivo

Implementare ricerca full-text su **Pagine** ed **Esercizi** usando SQLite FTS5, con estrazione automatica del contenuto dagli HTML originali.

## Contenuto Ricercabile

### Pagina
- **title**: titolo della pagina
- **content**: concatenazione di:
  - Testo estratto dall'HTML originale (`assets/images/{disciplina}/p{numero}/`)
  - `sottotitolo`
  - `"Pagina {numero}"`
  - `disciplina.nome` (es. "Matematica")
  - `volume.nome` (es. "Nuovi Itinerari 4")
  - `corso.nome` (es. "Nuovi Traguardi")
  - `"Classe {corso.classe}"` (es. "Classe 4")

### Esercizio
- **title**: titolo dell'esercizio
- **content**: description + category + tags

## Architettura

### Tabelle

1. **`search_records`** (tabella normale)
   - `searchable_type`, `searchable_id` (polymorphic)
   - `pagina_id`, `disciplina_id`, `volume_id` (foreign keys per filtri)
   - `title`, `content`
   - `timestamps`

2. **`search_records_fts`** (tabella virtuale FTS5)
   - `title`, `content`
   - Porter stemmer per italiano
   - Sincronizzata via `rowid` con `search_records.id`

### Estrazione HTML

Il rake task `search:rebuild`:
1. Per ogni Pagina, trova `assets/images/{disciplina.code}/p{numero}/`
2. Seleziona il file `.html` con timestamp più alto nel nome (es. `1722009901050.html` > `1715932804050.html`)
3. Estrae testo pulito (strip HTML tags)
4. Concatena con metadati contestuali

### Callback Automatici

- `after_create_commit` / `after_update_commit` → aggiorna indice (solo metadati per Pagine)
- `after_destroy_commit` → rimuove da indice

**Nota:** Per aggiornare il contenuto HTML serve `rails search:rebuild`

## Interfaccia Utente

### Route
```
GET /search → searches#show
```

### Pagina di Ricerca

1. **Barra di ricerca**
   - Campo testo con autofocus
   - Placeholder: "Cerca pagine ed esercizi..."
   - Pulsante "Cerca"

2. **Risultati**
   - Badge colorato: "Pagina" (blu) / "Esercizio" (verde)
   - Titolo con termini evidenziati (`<mark>`)
   - Snippet di contenuto (~20 parole)
   - Breadcrumb: Corso › Volume › Disciplina › Pagina N

3. **Link**
   - Pagina → `/pagine/{slug}`
   - Esercizio → `/e/{share_token}`

## File da Creare/Modificare

| File | Azione |
|------|--------|
| `db/migrate/XXX_create_search_records.rb` | Creare |
| `app/models/search/record.rb` | Creare |
| `app/models/concerns/searchable.rb` | Creare |
| `app/models/pagina.rb` | Modificare |
| `app/models/esercizio.rb` | Modificare |
| `app/controllers/searches_controller.rb` | Creare |
| `app/views/searches/show.html.erb` | Creare |
| `config/routes.rb` | Modificare |
| `lib/tasks/search.rake` | Creare |

## Comandi di Esecuzione

```bash
# 1. Esegui migration
bin/rails db:migrate

# 2. Ricostruisci indice
bin/rails search:rebuild

# 3. Testa
open http://localhost:3000/search?q=divisione
```

## Decisioni di Design

1. **File HTML più recente**: usa il timestamp nel nome file per scegliere la versione aggiornata
2. **Metadati nel content**: invece di filtri separati, includiamo disciplina/volume/corso/classe nel testo ricercabile
3. **Nessun filtro UI**: la ricerca full-text con metadati è sufficiente (YAGNI)
4. **Porter stemmer**: migliora match per parole italiane (divisioni → divis)
