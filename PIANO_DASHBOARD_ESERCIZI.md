# 📚 Piano Dashboard Costruttore di Esercizi

## FASE 1: Database e Modelli (Backend)

### 1.1 Creazione tabelle database
- **esercizi**: memorizza esercizi composti
  - title, description, slug (per URL)
  - category, tags[], difficulty
  - content (JSON con configurazione operazioni)
  - published_at, views_count
  - share_token (per link condivisibili)

- **esercizio_templates**: template predefiniti
  - name, description, category
  - default_config (JSON)
  - usage_count

- **esercizio_attempts**: tracking risultati studenti
  - esercizio_id, student_identifier
  - started_at, completed_at
  - results (JSON), score
  - time_spent

### 1.2 Modelli ActiveRecord
- `Esercizio` con serializzazione JSON per content
- `EsercizioTemplate` per template riutilizzabili
- `EsercizioAttempt` per tracking
- Concern `Shareable` per gestione link condivisibili

## FASE 2: Controller e Routes

### 2.1 EserciziController (area admin/dashboard)
- `index`: lista esercizi con filtri (categoria, tag, data)
- `new/create`: builder con drag & drop
- `edit/update`: modifica esercizi esistenti
- `duplicate`: clona esercizio
- `preview`: anteprima live durante creazione
- `export_pdf`: generazione PDF

### 2.2 PublicEserciziController (area studenti)
- `show`: visualizza esercizio via share_token
- `attempt`: salva tentativo studente
- `results`: mostra risultati

### 2.3 Routes strutturate
```ruby
namespace :dashboard do
  resources :esercizi do
    member do
      post :duplicate
      get :preview
      get :export_pdf
    end
  end
  resources :esercizio_templates
end

# Area pubblica
get 'e/:share_token', to: 'public_esercizi#show'
post 'e/:share_token/attempt', to: 'public_esercizi#attempt'
```

## FASE 3: UI Dashboard Builder

### 3.1 Layout principale dashboard
- **Sidebar sinistra**:
  - Lista generatori disponibili (Addizioni, Sottrazioni, etc.)
  - Template predefiniti
  - Filtri e ricerca

- **Area centrale**: Canvas drag & drop
  - Griglia con snap-to-grid
  - Ridimensionamento operazioni
  - Anteprima live

- **Sidebar destra**:
  - Proprietà elemento selezionato
  - Opzioni globali esercizio
  - Azioni (Salva, Pubblica, Esporta)

### 3.2 Componente EsercizioBuilder (Stimulus)
- `esercizio_builder_controller.js`:
  - Drag & drop con Sortable.js
  - Gestione stato operazioni
  - Serializzazione/deserializzazione
  - Anteprima real-time

## FASE 4: Sistema di Rendering

### 4.1 EsercizioRenderer
- Service object che:
  - Deserializza configurazione JSON
  - Istanzia modelli appropriati (Addizione, Sottrazione, etc.)
  - Renderizza partial corretti in ordine
  - Gestisce layout responsive

### 4.2 Adattamento partial esistenti
- Aggiungere wrapper container per drag & drop
- Data attributes per identificazione univoca
- Supporto modalità "readonly" per area pubblica

## FASE 5: Sistema di Condivisione

### 5.1 Generazione link
- Token univoci non sequenziali
- URL brevi (es. `/e/abc123`)
- QR code opzionale
- Scadenza opzionale

### 5.2 Pagina pubblica studente
- Layout pulito senza navigazione
- Timer opzionale
- Pulsante "Consegna"
- Feedback immediato o differito

## FASE 6: Export e Template

### 6.1 Export PDF
- Utilizzo Prawn o WickedPDF
- Layout ottimizzato per stampa
- Inclusione/esclusione soluzioni
- Batch export per più esercizi

### 6.2 Sistema Template
- CRUD template nella dashboard
- Categorie: Base, Intermedio, Avanzato
- Template parametrizzati (es. "N addizioni fino a M")
- Sharing template tra utenti (futuro)

## FASE 7: Tracking e Statistiche

### 7.1 Dashboard statistiche
- Vista aggregata per esercizio
- Tempo medio completamento
- Tasso successo per operazione
- Errori comuni

### 7.2 Report studente
- Storico tentativi
- Progressi nel tempo
- Export report

## 🛠️ Stack Tecnologico

- **Backend**: Rails models, PostgreSQL JSON columns
- **Frontend**: Stimulus.js, Sortable.js per drag & drop
- **Stile**: Tailwind CSS esistente
- **PDF**: Prawn o WickedPDF
- **Charts**: Chart.js per statistiche

## 📅 Ordine di Implementazione

1. **Database e modelli base** (Esercizio, migrations)
2. **Dashboard UI con builder drag & drop**
3. **Sistema di rendering unificato**
4. **Condivisione con link pubblici**
5. **Template predefiniti**
6. **Export PDF**
7. **Tracking risultati e statistiche**

## 🎯 Prima Milestone

Dashboard funzionante con:
- Creazione esercizi multi-operazione
- Drag & drop per posizionamento
- Salvataggio nel database
- Link condivisibile base
- Visualizzazione pubblica

## 📝 Note sulle Preferenze Utente

- **Organizzazione**: Sistema misto (classe/materia, argomenti, collezioni personalizzate, tag)
- **Accesso**: Studenti con link condivisibili
- **Funzionalità extra**:
  - Template predefiniti
  - Tracking risultati
  - Export PDF
  - Duplica/Modifica esercizi
- **Layout**: Drag & drop per posizionamento manuale delle operazioni