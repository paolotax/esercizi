# Unificazione Partial Quaderno Grid

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Unificare i 4 partial duplicati `_addizione_grid`, `_sottrazione_grid`, `_moltiplicazione_grid`, `_divisione_grid` in un unico partial `_quaderno_grid.html.erb`.

**Architecture:** I 4 partial sono identici al 98%. Le differenze sono:
1. Colore bordo in column style (blu/rosso/verde/arancione)
2. La divisione non ha colonna segni (skip `columns - 2` invece di `columns - 3`)
3. La divisione non mostra i segni fuori dal box

Aggiungiamo `border_color` e `operation_type` alla grid matrix per gestire queste differenze.

**Tech Stack:** Rails ERB, Tailwind CSS

---

## Task 1: Estendi i Renderer per passare metadati operazione

**Files:**
- Modify: `app/models/addizione/renderer.rb:270-279`
- Modify: `app/models/sottrazione/renderer.rb:148-157`
- Modify: `app/models/moltiplicazione/renderer.rb:440-449`
- Modify: `app/models/divisione/renderer.rb:311-322`

**Step 1: Modifica Addizione::Renderer#to_grid_matrix**

In `app/models/addizione/renderer.rb`, aggiungi `border_color` e `operation_type` al hash restituito:

```ruby
# Trova il blocco finale di to_grid_matrix (circa linea 270-279)
# Sostituisci:
{
  columns: total_cols,
  cell_size: cell_size,
  controller: "quaderno",
  title: @title,
  show_toolbar: @show_toolbar,
  style: @grid_style,
  rows: rows
}

# Con:
{
  columns: total_cols,
  cell_size: cell_size,
  controller: "quaderno",
  title: @title,
  show_toolbar: @show_toolbar,
  style: @grid_style,
  operation_type: :addizione,
  border_color: "blue",
  rows: rows
}
```

**Step 2: Modifica Sottrazione::Renderer#to_grid_matrix**

In `app/models/sottrazione/renderer.rb`, aggiungi `border_color` e `operation_type`:

```ruby
# Trova il blocco finale di to_grid_matrix (circa linea 148-157)
{
  columns: total_cols,
  cell_size: cell_size,
  controller: "quaderno",
  title: @title,
  show_toolbar: @show_toolbar,
  style: @grid_style,
  operation_type: :sottrazione,
  border_color: "red",
  rows: rows
}
```

**Step 3: Modifica Moltiplicazione::Renderer#to_grid_matrix**

In `app/models/moltiplicazione/renderer.rb`, aggiungi `border_color` e `operation_type`:

```ruby
# Trova il blocco finale di to_grid_matrix (circa linea 440-449)
{
  columns: total_cols,
  cell_size: cell_size,
  controller: "quaderno",
  title: nil,
  show_toolbar: @show_toolbar,
  style: @grid_style,
  operation_type: :moltiplicazione,
  border_color: "green",
  rows: rows
}
```

**Step 4: Modifica Divisione::Renderer#to_grid_matrix**

In `app/models/divisione/renderer.rb`, aggiungi `border_color` e `operation_type`:

```ruby
# Trova il blocco finale di to_grid_matrix (circa linea 311-322)
{
  columns: total_cols,
  cell_size: cell_size,
  controller: "quaderno",
  title: @title,
  show_toolbar: @show_toolbar,
  show_steps_button: true,
  separator_col: left_cols,
  remainder: has_remainder? ? @remainder : nil,
  operation_type: :divisione,
  border_color: "orange",
  rows: rows
}
```

**Step 5: Verifica sintassi Ruby**

Run:
```bash
ruby -c app/models/addizione/renderer.rb && \
ruby -c app/models/sottrazione/renderer.rb && \
ruby -c app/models/moltiplicazione/renderer.rb && \
ruby -c app/models/divisione/renderer.rb
```

Expected: `Syntax OK` per tutti i file

**Step 6: Commit**

```bash
git add app/models/*/renderer.rb
git commit -m "feat: add operation_type and border_color to grid matrix"
```

---

## Task 2: Crea il partial unificato _quaderno_grid

**Files:**
- Create: `app/views/strumenti/_quaderno_grid.html.erb`

**Step 1: Crea il nuovo partial unificato**

Crea `app/views/strumenti/_quaderno_grid.html.erb` con il contenuto di `_addizione_grid.html.erb` modificato per gestire tutte le operazioni:

```erb
<%#
  Partial unificato per quaderno operazioni (addizione, sottrazione, moltiplicazione, divisione)

  Riceve: grid (hash da to_grid_matrix)
    - columns: numero colonne
    - cell_size: dimensione celle (default "2.5em")
    - controller: nome controller Stimulus (default "quaderno")
    - title: titolo opzionale
    - show_toolbar: se mostrare la toolbar
    - rows: array di righe
    - style: :quaderno (default, quadretti) o :column (bordi colorati, segni fuori)
    - operation_type: :addizione, :sottrazione, :moltiplicazione, :divisione
    - border_color: "blue", "red", "green", "orange"
%>

<%
  columns = grid[:columns]
  cell_size = grid[:cell_size] || "2.5em"
  controller_name = grid[:controller] || "quaderno"
  title = grid[:title]
  show_toolbar = grid[:show_toolbar]
  show_steps_button = grid[:show_steps_button] || false
  rows = grid[:rows]
  grid_style = grid[:style]&.to_sym || :quaderno
  is_column_style = grid_style == :column
  operation_type = grid[:operation_type]&.to_sym || :addizione
  border_color = grid[:border_color] || "blue"
  is_divisione = operation_type == :divisione

  # Mappa colori bordo
  border_color_class = case border_color
                       when "blue" then "border-blue-400"
                       when "red" then "border-red-400"
                       when "green" then "border-green-400"
                       when "orange" then "border-orange-400"
                       else "border-blue-400"
                       end

  # Divisione: columns - 2 (no colonna segni), altre: columns - 3
  column_style_cols = is_divisione ? columns - 2 : columns - 3
%>

<div class="inline-block" data-controller="<%= controller_name %>">

  <% if title.present? %>
    <div class="font-mono font-bold mb-4 text-gray-700 dark:text-gray-200 bg-gray-100 dark:bg-gray-800 px-4 py-2 rounded inline-block"><%= title %></div>
  <% end %>

  <% if is_column_style %>
    <%# Stile column: bordo colorato, segni fuori (rimuovi margini e colonna segni) %>
    <div class="flex items-start justify-center gap-2">
      <div class="inline-grid border-4 <%= border_color_class %> rounded-lg bg-white dark:bg-gray-800"
           style="grid-template-columns: repeat(<%= column_style_cols %>, <%= cell_size %>);">
  <% else %>
    <%# Stile quaderno: quadretti %>
    <div class="inline-grid border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-900"
         style="grid-template-columns: repeat(<%= columns %>, <%= cell_size %>);">
  <% end %>

    <% rows.each_with_index do |row, row_idx| %>
      <%
        row_height = row[:height] || cell_size
        is_last_row = (row_idx == rows.length - 1)
        next_row = rows[row_idx + 1] if row_idx < rows.length - 1
        next_is_toolbar = next_row && next_row[:type] == :toolbar
      %>

      <% if row[:type] == :empty %>
        <%# Riga vuota %>
        <% if is_column_style %>
          <%# Column style: skip margini %>
        <% else %>
          <% columns.times do |col| %>
            <%
              is_last_col = (col == columns - 1)
              border_classes = ""
              border_classes += " border-r border-gray-300 dark:border-gray-600" unless is_last_col
              border_classes += " border-b border-gray-300 dark:border-gray-600" unless is_last_row || next_is_toolbar
            %>
            <div class="<%= border_classes %>" style="height: <%= row_height %>;"></div>
          <% end %>
        <% end %>

      <% elsif row[:type] == :cells || row[:type] == :result || row[:type] == :separator %>
        <%# Riga con celle %>
        <%
          has_separator = row[:separator_col]
          is_result_row = row[:type] == :result
          row_has_thick_border = row[:thick_border_top] || is_result_row
          is_labels_row = row[:cells]&.any? { |c| c[:type] == :label }
        %>
        <% row[:cells].each_with_index do |cell, col| %>
          <%
            is_last_col = (col == columns - 1)
            is_first_col = (col == 0)
            is_last_two_cols = (col >= columns - 2)
            is_sign_col = (col == columns - 2)

            # Column style: skip colonne in base al tipo operazione
            if is_column_style
              if is_divisione
                # Divisione: skip solo margini (prima e ultima colonna)
                next if is_first_col || is_last_col
              else
                # Altre operazioni: skip prima colonna (margine), colonna segni e ultima (margine)
                next if is_first_col || is_last_col || is_sign_col
              end
            end

            is_in_data_area = !is_first_col && !is_last_two_cols
            cell_has_thick_border = cell[:thick_border_top]
            has_thick_top = (row_has_thick_border && is_in_data_area) || cell_has_thick_border

            border_classes = ""
            if is_column_style
              # Calcola ultima colonna visibile in base al tipo
              is_last_visible_col = is_divisione ? (col == columns - 2) : (col == columns - 3)
              border_classes += " border-r border-gray-300 dark:border-gray-600" unless is_last_visible_col
              border_classes += " border-b-2 border-gray-300 dark:border-gray-600" if is_labels_row
              border_classes += " border-t-4 border-gray-500 dark:border-gray-400" if is_result_row
            else
              border_classes += " border-r border-gray-300 dark:border-gray-600" unless is_last_col
              border_classes += " border-b border-gray-300 dark:border-gray-600" unless is_last_row || next_is_toolbar
              border_classes += " border-t-2 border-t-gray-700 dark:border-t-gray-300" if has_thick_top
            end
            border_classes += " border-l-2 border-l-gray-700 dark:border-l-gray-300" if has_separator && col == has_separator

            bg_class = cell[:bg_class] || ""
            is_result_cell = cell[:target] == "result"
            bg_class = "bg-gray-50 dark:bg-gray-800" if (is_result_row || is_result_cell) && is_in_data_area && bg_class.blank? && !is_column_style
          %>

          <div class="<%= border_classes %> <%= bg_class %> relative" style="height: <%= row_height %>;">
            <% if cell[:type] == :empty %>
              <%# Cella vuota %>

            <% elsif cell[:editable] %>
              <%# Input editabile %>
              <%
                is_carry = cell[:target] == "carry"
                input_classes = is_carry ? "quaderno-input quaderno-input-carry" : "quaderno-input"
              %>
              <input type="text"
                     class="<%= input_classes %> bg-transparent focus:bg-blue-100/20 dark:focus:bg-blue-500/20 <%= cell[:classes] %>"
                     data-<%= controller_name %>-target="<%= cell[:target] %>"
                     <% if cell[:row] %>data-row="<%= cell[:row] %>"<% end %>
                     <% if cell[:col] %>data-col="<%= cell[:col] %>"<% end %>
                     data-correct-answer="<%= cell[:value] || '' %>"
                     data-nav-direction="<%= cell[:nav_direction] || 'ltr' %>"
                     maxlength="1"
                     inputmode="numeric"
                     <% if cell[:disabled] %>disabled<% end %>
                     <% if cell[:show_value] && cell[:value].present? %>value="<%= cell[:value] %>"<% end %>>

              <%# Comma spot (per virgola cliccabile) %>
              <% if cell[:comma_spot] %>
                <button type="button"
                        class="quaderno-comma-spot"
                        data-<%= controller_name %>-target="commaSpot"
                        data-correct-position="<%= cell[:comma_spot][:correct] %>"
                        data-position="<%= cell[:comma_spot][:position] %>"
                        data-action="click-><%= controller_name %>#toggleComma"
                        title="Clicca per inserire la virgola"></button>
              <% end %>

              <%# Comma shift (per virgola spostabile dividendo/divisore) %>
              <% if cell[:comma_shift] %>
                <button type="button"
                        class="quaderno-comma-shift"
                        data-<%= controller_name %>-target="commaShift"
                        data-comma-type="<%= cell[:comma_shift][:type] %>"
                        data-comma-position="<%= cell[:comma_shift][:position] %>"
                        data-should-shift="<%= cell[:comma_shift][:should_shift] %>"
                        data-action="click-><%= controller_name %>#shiftComma"
                        title="Clicca per spostare la virgola">,</button>
              <% end %>

              <%# Virgola statica (mostrata tra celle) %>
              <% if cell[:show_comma] %>
                <span class="quaderno-comma text-gray-800 dark:text-gray-100">,</span>
              <% end %>

            <% elsif cell[:type] == :sign %>
              <%# Segno operazione (non editabile) %>
              <div class="w-full h-full flex items-center justify-center <%= cell[:classes] %> font-bold">
                <%= cell[:value] %>
              </div>

            <% elsif cell[:type] == :label %>
              <%# Etichetta colonna %>
              <div class="w-full h-full flex items-center justify-center font-bold <%= cell[:classes] %>">
                <%= cell[:value] %>
              </div>

            <% elsif cell[:type] == :static %>
              <%# Testo statico (es. zero placeholder nei prodotti parziali) %>
              <div class="w-full h-full flex items-center justify-center <%= cell[:classes] %>">
                <%= cell[:value] %>
              </div>

            <% else %>
              <%# Fallback: mostra valore se presente %>
              <% if cell[:value].present? %>
                <div class="w-full h-full flex items-center justify-center"><%= cell[:value] %></div>
              <% end %>
            <% end %>
          </div>
        <% end %>

      <% elsif row[:type] == :toolbar %>
        <%# Riga toolbar %>
        <% if is_column_style %>
          <%# Column style: toolbar fuori dal grid %>
        <% else %>
          <%= render "strumenti/quaderno_toolbar", total_cols: columns, show_steps_button: show_steps_button %>
        <% end %>
      <% end %>
    <% end %>

  <% if is_column_style %>
    </div><%# Fine grid interno per column style %>
    <% unless is_divisione %>
      <%# Column style: colonna segni fuori dal box (non per divisione) %>
      <%
        all_signs = []
        rows.each do |row|
          next if row[:type] == :empty || row[:type] == :toolbar
          row_height = row[:height] || cell_size
          sign_cell = row[:cells]&.find { |c| c[:type] == :sign }
          if sign_cell
            all_signs << { value: sign_cell[:value], classes: sign_cell[:classes], height: row_height }
          else
            all_signs << { value: "", classes: "", height: row_height }
          end
        end
      %>
      <div class="flex flex-col">
        <% all_signs.each do |sign| %>
          <div class="font-bold flex items-center justify-center <%= sign[:classes] %>"
               style="height: <%= sign[:height] %>; width: <%= cell_size %>;">
            <%= sign[:value] %>
          </div>
        <% end %>
      </div>
    <% end %>
  </div><%# Fine flex container per column style %>
  <% else %>
  </div><%# Fine quaderno grid %>
  <% end %>

  <%# Toolbar per column style (fuori dal grid) %>
  <% if is_column_style && show_toolbar %>
    <div class="flex justify-center gap-4 mt-6 print:hidden">
      <%= render "strumenti/quaderno_toolbar_buttons" %>
    </div>
  <% end %>

  <%# Resto finale per divisione %>
  <% if grid[:remainder].present? %>
    <div class="mt-2 text-sm text-gray-600 dark:text-gray-400">
      Resto: <span class="font-bold text-orange-600 dark:text-orange-400"><%= grid[:remainder] %></span>
    </div>
  <% end %>

</div>
```

**Step 2: Verifica sintassi ERB**

Run:
```bash
erb -x app/views/strumenti/_quaderno_grid.html.erb | ruby -c
```

Expected: `Syntax OK`

**Step 3: Commit**

```bash
git add app/views/strumenti/_quaderno_grid.html.erb
git commit -m "feat: create unified _quaderno_grid partial"
```

---

## Task 3: Aggiorna OperazioniHelper per usare il partial unificato

**Files:**
- Modify: `app/helpers/operazioni_helper.rb:60,99,140,177`

**Step 1: Modifica addizione_grid helper**

In `app/helpers/operazioni_helper.rb`, cambia la linea 60:

```ruby
# Da:
render "strumenti/addizioni/addizione_grid", grid: renderer.to_grid_matrix

# A:
render "strumenti/quaderno_grid", grid: renderer.to_grid_matrix
```

**Step 2: Modifica sottrazione_grid helper**

Cambia la linea 99:

```ruby
# Da:
render "strumenti/sottrazioni/sottrazione_grid", grid: renderer.to_grid_matrix

# A:
render "strumenti/quaderno_grid", grid: renderer.to_grid_matrix
```

**Step 3: Modifica moltiplicazione_grid helper**

Cambia la linea 140:

```ruby
# Da:
render "strumenti/moltiplicazioni/moltiplicazione_grid", grid: renderer.to_grid_matrix

# A:
render "strumenti/quaderno_grid", grid: renderer.to_grid_matrix
```

**Step 4: Modifica divisione_grid helper**

Cambia la linea 177:

```ruby
# Da:
render "strumenti/divisioni/divisione_grid", grid: renderer.to_grid_matrix

# A:
render "strumenti/quaderno_grid", grid: renderer.to_grid_matrix
```

**Step 5: Verifica sintassi Ruby**

Run:
```bash
ruby -c app/helpers/operazioni_helper.rb
```

Expected: `Syntax OK`

**Step 6: Commit**

```bash
git add app/helpers/operazioni_helper.rb
git commit -m "refactor: use unified _quaderno_grid partial in helpers"
```

---

## Task 4: Aggiorna le view strumenti per usare il partial unificato

**Files:**
- Modify: `app/views/strumenti/addizioni/show.html.erb:29,177`
- Modify: `app/views/strumenti/addizioni/preview.html.erb:11`
- Modify: `app/views/strumenti/sottrazioni/show.html.erb:29,178`
- Modify: `app/views/strumenti/sottrazioni/preview.html.erb:11`
- Modify: `app/views/strumenti/moltiplicazioni/show.html.erb:29,185`
- Modify: `app/views/strumenti/moltiplicazioni/preview.html.erb:11`
- Modify: `app/views/strumenti/divisioni/show.html.erb:29,152`
- Modify: `app/views/strumenti/divisioni/preview.html.erb:11`

**Step 1: Aggiorna addizioni/show.html.erb**

Cambia le chiamate render:

```erb
<%# Linea 29 - Da: %>
<%= render "strumenti/addizioni/addizione_grid",
<%# A: %>
<%= render "strumenti/quaderno_grid",

<%# Linea 177 - Da: %>
<%= render "strumenti/addizioni/addizione_grid", grid: addizione.to_grid_matrix %>
<%# A: %>
<%= render "strumenti/quaderno_grid", grid: addizione.to_grid_matrix %>
```

**Step 2: Aggiorna addizioni/preview.html.erb**

```erb
<%# Linea 11 - Da: %>
<%= render "strumenti/addizioni/addizione_grid",
<%# A: %>
<%= render "strumenti/quaderno_grid",
```

**Step 3: Aggiorna sottrazioni/show.html.erb**

```erb
<%# Linea 29 - Da: %>
<%= render "strumenti/sottrazioni/sottrazione_grid",
<%# A: %>
<%= render "strumenti/quaderno_grid",

<%# Linea 178 - Da: %>
<%= render "strumenti/sottrazioni/sottrazione_grid", grid: sottrazione.to_grid_matrix %>
<%# A: %>
<%= render "strumenti/quaderno_grid", grid: sottrazione.to_grid_matrix %>
```

**Step 4: Aggiorna sottrazioni/preview.html.erb**

```erb
<%# Linea 11 - Da: %>
<%= render "strumenti/sottrazioni/sottrazione_grid",
<%# A: %>
<%= render "strumenti/quaderno_grid",
```

**Step 5: Aggiorna moltiplicazioni/show.html.erb**

```erb
<%# Linea 29 - Da: %>
<%= render "strumenti/moltiplicazioni/moltiplicazione_grid",
<%# A: %>
<%= render "strumenti/quaderno_grid",

<%# Linea 185 - Da: %>
<%= render "strumenti/moltiplicazioni/moltiplicazione_grid", grid: moltiplicazione.to_grid_matrix %>
<%# A: %>
<%= render "strumenti/quaderno_grid", grid: moltiplicazione.to_grid_matrix %>
```

**Step 6: Aggiorna moltiplicazioni/preview.html.erb**

```erb
<%# Linea 11 - Da: %>
<%= render "strumenti/moltiplicazioni/moltiplicazione_grid",
<%# A: %>
<%= render "strumenti/quaderno_grid",
```

**Step 7: Aggiorna divisioni/show.html.erb**

```erb
<%# Linea 29 - Da: %>
<%= render "strumenti/divisioni/divisione_grid",
<%# A: %>
<%= render "strumenti/quaderno_grid",

<%# Linea 152 - Da: %>
<%= render "strumenti/divisioni/divisione_grid", grid: divisione.to_grid_matrix %>
<%# A: %>
<%= render "strumenti/quaderno_grid", grid: divisione.to_grid_matrix %>
```

**Step 8: Aggiorna divisioni/preview.html.erb**

```erb
<%# Linea 11 - Da: %>
<%= render "strumenti/divisioni/divisione_grid",
<%# A: %>
<%= render "strumenti/quaderno_grid",
```

**Step 9: Commit**

```bash
git add app/views/strumenti/*/show.html.erb app/views/strumenti/*/preview.html.erb
git commit -m "refactor: update strumenti views to use unified partial"
```

---

## Task 5: Test manuale delle 4 operazioni

**Step 1: Avvia il server Rails**

Run:
```bash
bin/rails server
```

**Step 2: Testa addizioni**

Visita: `http://localhost:3000/strumenti/addizioni`
- Verifica che l'esempio con numeri interi funzioni
- Verifica che l'esempio con decimali funzioni
- Testa lo stile "column" (bordo blu)
- Testa lo stile "quaderno" (quadretti)

**Step 3: Testa sottrazioni**

Visita: `http://localhost:3000/strumenti/sottrazioni`
- Verifica bordo rosso in column style
- Verifica prestiti funzionanti

**Step 4: Testa moltiplicazioni**

Visita: `http://localhost:3000/strumenti/moltiplicazioni`
- Verifica bordo verde in column style
- Verifica prodotti parziali

**Step 5: Testa divisioni**

Visita: `http://localhost:3000/strumenti/divisioni`
- Verifica bordo arancione in column style
- Verifica che i segni NON appaiano fuori dal box
- Verifica passi intermedi

**Step 6: Testa pagine esercizi**

Visita alcune pagine che usano gli helper:
- `http://localhost:3000/pagine/nvi4_mat_p006`
- `http://localhost:3000/pagine/nvi4_mat_p007`

---

## Task 6: Elimina i vecchi partial duplicati

**Files:**
- Delete: `app/views/strumenti/addizioni/_addizione_grid.html.erb`
- Delete: `app/views/strumenti/sottrazioni/_sottrazione_grid.html.erb`
- Delete: `app/views/strumenti/moltiplicazioni/_moltiplicazione_grid.html.erb`
- Delete: `app/views/strumenti/divisioni/_divisione_grid.html.erb`

**Step 1: Rimuovi i vecchi partial**

Run:
```bash
rm app/views/strumenti/addizioni/_addizione_grid.html.erb
rm app/views/strumenti/sottrazioni/_sottrazione_grid.html.erb
rm app/views/strumenti/moltiplicazioni/_moltiplicazione_grid.html.erb
rm app/views/strumenti/divisioni/_divisione_grid.html.erb
```

**Step 2: Verifica che non ci siano riferimenti rimasti**

Run:
```bash
grep -r "addizione_grid\|sottrazione_grid\|moltiplicazione_grid\|divisione_grid" app/views/strumenti/
```

Expected: Nessun output (nessun riferimento ai vecchi partial)

**Step 3: Commit**

```bash
git add -A
git commit -m "chore: remove deprecated operation-specific grid partials"
```

---

## Task 7: Esegui test suite completa

**Step 1: Esegui tutti i test**

Run:
```bash
bin/rails test
```

Expected: Tutti i test passano

**Step 2: Commit finale**

```bash
git add -A
git commit -m "refactor: complete unification of quaderno grid partials

- Created unified _quaderno_grid.html.erb partial
- Added operation_type and border_color to grid matrix
- Updated all helpers and views to use unified partial
- Removed 4 duplicate partials (~1000 lines of duplicated code)"
```

---

## Riepilogo modifiche

| File | Azione |
|------|--------|
| `app/models/addizione/renderer.rb` | Aggiungi `operation_type: :addizione, border_color: "blue"` |
| `app/models/sottrazione/renderer.rb` | Aggiungi `operation_type: :sottrazione, border_color: "red"` |
| `app/models/moltiplicazione/renderer.rb` | Aggiungi `operation_type: :moltiplicazione, border_color: "green"` |
| `app/models/divisione/renderer.rb` | Aggiungi `operation_type: :divisione, border_color: "orange"` |
| `app/views/strumenti/_quaderno_grid.html.erb` | **NUOVO** - Partial unificato |
| `app/helpers/operazioni_helper.rb` | Usa `strumenti/quaderno_grid` |
| `app/views/strumenti/*/show.html.erb` | Usa `strumenti/quaderno_grid` |
| `app/views/strumenti/*/preview.html.erb` | Usa `strumenti/quaderno_grid` |
| `app/views/strumenti/*/_*_grid.html.erb` | **ELIMINATI** - 4 partial duplicati |

**Linee di codice rimosse:** ~1000 (4 partial x 248 linee ciascuno)
**Linee di codice aggiunte:** ~260 (1 partial unificato)
**Risparmio netto:** ~740 linee
