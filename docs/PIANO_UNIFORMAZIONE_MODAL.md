# Confronto e Piano di Uniformazione: Modal Operazioni vs Dashboard Builder

## 1. DOCUMENTAZIONE SISTEMI ESISTENTI

### Sistema A: Column Modal (Pagine Esercizi Studenti)

**Scopo**: Permettere agli studenti di svolgere operazioni in colonna in un modal

**File principali**:
| File | Funzione |
|------|----------|
| `app/javascript/controllers/column_modal_controller.js` | Controller Stimulus (318 righe) |
| `app/views/shared/_column_modal.html.erb` | Partial modal condiviso |
| `app/views/exercises/_column_operations_grid.html.erb` | Grid operazioni dinamico |
| `app/controllers/exercises_controller.rb` | Endpoint `column_operations_grid` |

**Flusso**:
```
[Bottone Gruppo] → openGroup() → fetch(/exercises/column_operations_grid)
    → [Modal con griglie] → saveGroup() → [Verifica + Update UI]
```

**Data Attributes**:
- `data-operations="36x12,37x14"` - operazioni separate da virgola
- `data-group="a"` - identificatore gruppo
- `data-show-carry="true"` - mostra riporti
- `data-show-borrow="true"` - mostra prestiti
- `data-with-proof="true"` - mostra prova
- `data-column-modal-target="groupButton|operationsList|modal|grid|title"`

**Tipi operazione supportati**: `+` (addizione), `-` (sottrazione), `x` (moltiplicazione)

**Pagine che usano questo sistema**:
- `bus3_mat_p025.html.erb` - Addizioni
- `bus3_mat_p026.html.erb` - Addizioni con riporto
- `bus3_mat_p027.html.erb` - Addizioni con prova
- `bus3_mat_p030.html.erb` - Sottrazioni
- `bus3_mat_p031.html.erb` - Sottrazioni
- `bus3_mat_p032.html.erb` - Sottrazioni con prestito
- `bus3_mat_p033.html.erb` - Sottrazioni con prova
- `bus3_mat_p048.html.erb` - Moltiplicazioni

---

### Sistema B: Dashboard Builder (Creazione Esercizi Insegnanti)

**Scopo**: Creare esercizi tramite drag-and-drop con pannello proprietà

**File principali**:
| File | Funzione |
|------|----------|
| `app/javascript/controllers/esercizio_builder_controller.js` | D&D core (750+ righe) |
| `app/javascript/controllers/properties_panel_controller.js` | Panel manager (68 righe) |
| `app/views/dashboard/esercizi/edit.html.erb` | Layout 3 colonne |
| `app/views/dashboard/esercizi/_operation_card.html.erb` | Card preview |
| `app/views/dashboard/esercizi/_operation_properties_panel.html.erb` | Panel laterale |
| `app/views/dashboard/esercizi/_addizione_form.html.erb` | Form config addizione |
| `app/views/dashboard/esercizi/_sottrazione_form.html.erb` | Form config sottrazione |
| `app/views/dashboard/esercizi/_moltiplicazione_form.html.erb` | Form config moltiplicazione |
| `app/controllers/dashboard/esercizi_controller.rb` | CRUD + endpoints custom |

**Flusso**:
```
[Drag Generatore] → handleDrop() → POST /add_operation → [Card Preview]
    → [Click Card] → open-properties event → [Panel Slide-out] → PATCH /update_operation
```

**Model Esercizio** (`content` JSON):
```ruby
{
  'operations' => [
    { 'id' => uuid, 'type' => 'addizione', 'config' => {...}, 'position' => 0 }
  ]
}
```

**Endpoints API**:
- `POST /dashboard/esercizi/{id}/add_operation` - Crea operazione
- `DELETE /dashboard/esercizi/{id}/remove_operation` - Elimina
- `PATCH /dashboard/esercizi/{id}/reorder_operations` - Riordina
- `GET /dashboard/esercizi/{id}/operation_properties` - Carica form proprietà
- `PATCH /dashboard/esercizi/{id}/update_operation` - Salva modifiche

---

## 2. TABELLA COMPARATIVA

| Aspetto | Column Modal | Dashboard Builder |
|---------|--------------|-------------------|
| **Utente** | Studenti | Insegnanti |
| **UI Pattern** | Modal centrato overlay | Panel slide-out + D&D |
| **Trigger** | Button click | Drag + Click |
| **Caricamento** | Fetch API | Fetch + Custom Events |
| **Persistenza** | `dataset` (sessione) | Database JSON |
| **Verifica** | Automatica JS | Nessuna |
| **Operazioni** | Gruppi fissi (a,b,c,d) | Dinamiche (CRUD) |
| **Preview** | Griglia interattiva | Card con badge |
| **Animazione** | Show/hide | Transform translate-x |

---

## 3. COMPONENTI CONDIVISIBILI

### Già condivisi:
- Partial operazioni:
  - `strumenti/addizioni/_column_addition.html.erb`
  - `strumenti/sottrazioni/_column_subtraction.html.erb`
  - `strumenti/moltiplicazioni/_column_multiplication.html.erb`

### Potenzialmente condivisibili:
1. **`_column_modal.html.erb`** → usabile nel builder per preview live
2. **`_column_operations_grid.html.erb`** → generazione dinamica preview
3. **Endpoint `column_operations_grid`** → API unificata per rendering operazioni

---

## 4. PIANO DI UNIFORMAZIONE

### Fase 1: Standardizzare i Partial (basso impatto)
- Assicurarsi che tutti i partial operazioni abbiano interfaccia coerente
- Documentare i parametri accettati da ogni partial
- Verificare che i target Stimulus siano consistenti

### Fase 2: Creare Sistema Modal Unificato
Nuovo controller `unified_modal_controller.js`:
```javascript
// Supporta entrambe le modalità
static values = {
  mode: { type: String, default: 'centered' }, // 'centered' | 'slideout'
  position: { type: String, default: 'right' } // 'right' | 'left' | 'bottom'
}
```

### Fase 3: Aggiungere Preview Live al Builder
- Usare `column_operations_grid` per mostrare preview interattiva nel builder
- Aggiungere tab "Preview" nel properties panel
- Permettere test operazione prima di salvare

### Fase 4: Unificare Endpoint API
```ruby
# routes.rb
namespace :api do
  resources :operations, only: [] do
    collection do
      get :render_grid  # Unifica column_operations_grid
      post :validate    # Verifica correttezza (opzionale)
    end
  end
end
```

---

## 5. FILE DA MODIFICARE (per uniformazione)

### Controller JS:
- `column_modal_controller.js` → estrarre logica comune
- `esercizio_builder_controller.js` → usare modal unificato per preview
- Nuovo: `unified_modal_controller.js`

### Partial:
- `shared/_column_modal.html.erb` → aggiungere mode slideout
- `shared/_unified_modal.html.erb` (nuovo)

### Controller Rails:
- `exercises_controller.rb` → spostare `column_operations_grid` in concern/API
- `dashboard/esercizi_controller.rb` → usare stesso endpoint per preview

---

## 6. PRIORITÀ SUGGERITA

1. **Immediato**: Documentazione (questo file) ✅
2. **Breve termine**: Standardizzare parametri partial operazioni
3. **Medio termine**: Modal unificato con supporto entrambe modalità
4. **Lungo termine**: API unificata per rendering/validazione operazioni

---

## 7. NOTE TECNICHE

### Target Stimulus per tipo operazione:
- Addizioni: `data-column-addition-target="result"`
- Sottrazioni: `data-column-subtraction-target="result"`
- Moltiplicazioni: `data-column-multiplication-target="resultInput"` (diverso!)

### Formato operazioni nel data-attribute:
- Addizioni: `"216+372,385+414"`
- Sottrazioni: `"714-354,681-159"`
- Moltiplicazioni: `"36x12,37x14"` (usa `x` non `*`)

### Colori modal per tipo:
- blue: addizioni
- cyan: sottrazioni semplici
- red: sottrazioni con prestito/prova
- green: moltiplicazioni
- orange: misto

---

*Documento creato: 26 novembre 2025*
*Per ricaricare: leggi questo file e continua da dove hai lasciato*
