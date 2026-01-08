---
name: revisione-dark-mode
description: Revisiona pagine bus3_mat al pattern nvi5_mat (dark mode, controller, layout)
---

# Skill: Revisione Dark Mode bus3_mat

Aggiorna le pagine `exercises/bus3_mat_pXXX.html.erb` al pattern di `nvi5_mat` con supporto dark mode completo.

---

## Quando Usare

Usa questa skill per:
- Aggiornare pagine bus3_mat (107 pagine, da p086 a p192)
- Aggiungere dark mode e controller Stimulus mancanti
- Uniformare al pattern nvi5_mat

---

## WORKFLOW OPERATIVO

**IMPORTANTE: Processare 10 pagine alla volta, controllando ogni pagina singolarmente.**

### Per ogni batch di 10 pagine:
1. Leggere la pagina completa
2. Applicare le trasformazioni (vedi checklist sotto)
3. Verificare la pagina modificata
4. Passare alla successiva
5. **Dopo 10 pagine: FERMARSI e chiedere conferma all'utente**

### Pagine da saltare:
- Nessuna pagina da saltare in questo range

---

## Checklist Trasformazioni

### 1. Container Principale (OBBLIGATORIO)

```erb
<%# PRIMA %>
<div class="max-w-6xl mx-auto p-3 md:p-8 bg-white rounded-lg shadow-lg" data-controller="exercise-checker">

<%# DOPO %>
<div class="max-w-6xl mx-auto bg-white dark:bg-gray-900 text-black dark:text-white p-3 md:p-6 transition-colors duration-300"
     data-controller="exercise-checker text-toggle font-controls"
     data-text-toggle-target="content"
     data-font-controls-target="content">
```

**Modifiche:**
- Rimuovi `rounded-lg shadow-lg`
- Cambia `p-3 md:p-8` → `p-3 md:p-6`
- Aggiungi `dark:bg-gray-900 text-black dark:text-white transition-colors duration-300`
- Aggiungi controller `text-toggle font-controls`
- Aggiungi target `data-text-toggle-target="content"` e `data-font-controls-target="content"`

### 2. page_header (VERIFICARE)

Deve essere presente così (senza opzioni aggiuntive):
```erb
<%= render 'shared/page_header', pagina: @pagina %>
```

### 3. Wrapper Contenuto (OPZIONALE)

Se il contenuto non ha già uno spacing coerente, aggiungere dopo page_header:
```erb
<div class="space-y-6">
  <!-- contenuto esercizi -->
</div>
```
E chiuderlo prima di exercise_controls.

### 4. exercise_controls (OBBLIGATORIO)

```erb
<%# PRIMA %>
<%= render 'shared/exercise_controls', color: 'pink', current_page: 'bus3_mat_pXXX' %>

<%# DOPO %>
<%= render 'shared/exercise_controls' %>
```

**Rimuovi tutti i parametri** (`color`, `current_page`).

---

## Checklist Dark Mode Elementi Interni

### 5. Testi

| Prima | Dopo |
|-------|------|
| `text-gray-700` | `text-gray-700 dark:text-gray-200` |
| `text-gray-600` | `text-gray-600 dark:text-gray-400` |
| `text-gray-800` | `text-gray-800 dark:text-gray-200` |
| `text-cyan-700` | `text-cyan-700 dark:text-cyan-400` |
| (nessuna classe testo) | aggiungi `dark:text-white` se necessario |

### 6. Box Colorati

| Colore | Prima | Dopo |
|--------|-------|------|
| Giallo | `bg-yellow-100` | `bg-yellow-100 dark:bg-yellow-900/30` |
| Azzurro | `bg-cyan-100` | `bg-cyan-100 dark:bg-cyan-900/40` |
| Rosa | `bg-pink-100` | `bg-pink-100 dark:bg-pink-900/30` |
| Verde | `bg-green-100` | `bg-green-100 dark:bg-green-900/30` |
| Arancione | `bg-orange-100` | `bg-orange-100 dark:bg-orange-900/30` |
| Blu | `bg-blue-100` | `bg-blue-100 dark:bg-blue-900/30` |
| Bianco interno | `bg-white` | `bg-white dark:bg-gray-800` |

### 7. Bordi

| Prima | Dopo |
|-------|------|
| `border-yellow-400` | `border-yellow-400 dark:border-yellow-600` |
| `border-cyan-400` | `border-cyan-400 dark:border-cyan-500` |
| `border-cyan-200` | `border-cyan-200 dark:border-cyan-700` |
| `border-gray-400` | `border-gray-400 dark:border-gray-500` |
| `border-pink-400` | `border-pink-400 dark:border-pink-500` |
| `border-blue-200` | `border-blue-200 dark:border-blue-700` |

### 8. Input

```erb
<%# PRIMA %>
<input type="text" class="border-b-2 border-dotted border-gray-400 bg-transparent w-56 text-left focus:outline-none"

<%# DOPO %>
<input type="text" class="border-b-2 border-dotted border-gray-400 dark:border-gray-500 bg-transparent dark:text-white w-56 text-left focus:outline-none"
```

### 9. Link

```erb
<%# PRIMA %>
class="text-cyan-600 font-bold"

<%# DOPO %>
class="text-cyan-600 dark:text-cyan-400 font-bold"
```

### 10. Immagini (Box Bianco per Dark Mode)

Wrappare le immagini in un container con sfondo bianco per dark mode:

```erb
<%# PRIMA %>
<%= image_tag "figura.png", class: "w-48 h-auto" %>

<%# DOPO %>
<div class="dark:bg-white rounded-xl p-1 inline-block">
  <%= image_tag "figura.png", class: "w-48 h-auto rounded-lg" %>
</div>
```

---

## Target Pagine

```
bus3_mat_p086.html.erb → bus3_mat_p192.html.erb
Totale: 107 file
Batch: 10 pagine alla volta
```

## Riferimenti

### Pattern corretto (da copiare):
- `app/views/exercises/nvi5_mat_p012.html.erb`

### Partial:
- `app/views/shared/_page_header.html.erb`
- `app/views/shared/_exercise_controls.html.erb`
