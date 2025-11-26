# Debug del Drag & Drop

## 🔍 Passi per il Debug

### 1. Test con la pagina HTML semplice
Apri nel browser: http://localhost:3000/test-drag-drop.html

Questa pagina di test ti permette di verificare che il drag & drop funzioni a livello base nel browser.

### 2. Test nell'applicazione Rails
1. Vai alla pagina di edit di un esercizio
2. Apri la console del browser (F12)
3. Verifica che vedi questi messaggi nella console:
   - "✅ Esercizio Builder Controller connected!"
   - "Found X generators"
   - Dettagli sui generatori trovati

### 3. Durante il drag
Quando inizi a trascinare, dovresti vedere nella console:
```
handleDragStart - event target: DIV operation-generator
handleDragStart - generator found: true
handleDragStart - operationType: addizione
handleDragStart - set successfully, currentDragType: addizione, isNewOperation: true
```

### 4. Durante il drop
Quando rilasci, dovresti vedere:
```
=== handleDrop START ===
Target: DIV ...
Current state - isNewOperation: true, currentDragType: addizione, draggedElement: null
=> Adding NEW operation: addizione
Position calculated: 0
```

## 🐛 Problemi Comuni e Soluzioni

### Problema: "Il drag non inizia"
**Verifica:**
- Gli elementi hanno `draggable="true"`
- Non ci sono errori JavaScript nella console
- Il controller Stimulus è caricato

### Problema: "Il drop non funziona"
**Verifica:**
- La console mostra i log del handleDrop
- Le variabili di stato sono corrette (isNewOperation, currentDragType)
- Non ci sono errori 404 per le chiamate AJAX

### Problema: "Le operazioni non si salvano"
**Verifica:**
- Il server Rails risponde con status 200
- Il controller ha i metodi add_operation, remove_operation, reorder_operations
- Il CSRF token è presente

## 🔧 Modifiche Applicate

1. **Binding corretto degli eventi**: Le funzioni bound sono create una volta sola
2. **Uso di currentTarget**: Per ottenere sempre l'elemento corretto
3. **Variabili di istanza**: Come fonte primaria per il tipo di operazione
4. **Logging dettagliato**: Per facilitare il debug

## 📝 Test da Eseguire

1. **Nuova operazione**: Trascina un generatore nell'area vuota
2. **Riordinamento**: Trascina un'operazione esistente sopra/sotto un'altra
3. **Indicatori visivi**: Verifica che gli elementi diventino semi-trasparenti durante il drag
4. **Salvataggio**: Verifica che l'ordine sia salvato dopo il riordinamento

## 🚀 Comandi Utili

```bash
# Ricompila gli assets
bin/rails assets:precompile

# Verifica le route
bin/rails routes | grep esercizi

# Tail dei log del server
tail -f log/development.log

# Restart del server (se necessario)
bin/rails restart
```

## 📌 File Modificati

- `/app/javascript/controllers/esercizio_builder_controller.js` - Controller Stimulus principale
- `/public/test-drag-drop.html` - Pagina di test semplificata

Se il problema persiste, controlla:
1. La console del browser per errori JavaScript
2. La tab Network per verificare le chiamate AJAX
3. I log del server Rails per errori lato backend