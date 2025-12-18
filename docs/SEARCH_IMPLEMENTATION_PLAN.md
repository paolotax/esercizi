# Piano: Implementare Ricerca FTS5 in Esercizi

## Obiettivo
Aggiungere ricerca full-text su **Pagine** e **Esercizi** usando SQLite FTS5, seguendo il pattern di Fizzy.

## Contenuto Ricercabile
- **Pagina**: `titolo`, `sottotitolo`, `numero` + contesto (disciplina/volume/corso)
- **Esercizio**: `title`, `description`, `tags`, `category`

---

## Step 1: Creare la Migration

**File**: `db/migrate/XXXXXX_create_search_records.rb`

```ruby
class CreateSearchRecords < ActiveRecord::Migration[8.0]
  def up
    # Tabella normale per i dati
    create_table :search_records do |t|
      t.string :searchable_type, null: false
      t.references :searchable, null: false, polymorphic: true
      t.references :pagina, foreign_key: true
      t.references :disciplina, foreign_key: true
      t.references :volume, foreign_key: true
      t.string :title
      t.text :content
      t.timestamps
    end

    add_index :search_records, [:searchable_type, :searchable_id], unique: true

    # Tabella virtuale FTS5
    execute <<-SQL
      CREATE VIRTUAL TABLE search_records_fts USING fts5(
        title,
        content,
        tokenize='porter'
      )
    SQL
  end

  def down
    execute "DROP TABLE IF EXISTS search_records_fts"
    drop_table :search_records, if_exists: true
  end
end
```

---

## Step 2: Creare il Model Search::Record

**File**: `app/models/search/record.rb`

```ruby
class Search::Record < ApplicationRecord
  self.table_name = "search_records"

  belongs_to :searchable, polymorphic: true
  belongs_to :pagina, optional: true
  belongs_to :disciplina, optional: true
  belongs_to :volume, optional: true

  class << self
    def upsert!(searchable, attributes)
      record = find_or_initialize_by(
        searchable_type: searchable.class.name,
        searchable_id: searchable.id
      )
      record.update!(attributes)
      sync_fts(record)
      record
    end

    def remove!(searchable)
      record = find_by(
        searchable_type: searchable.class.name,
        searchable_id: searchable.id
      )
      return unless record

      remove_from_fts(record.id)
      record.destroy!
    end

    def search(query)
      return none if query.blank?

      sanitized = sanitize_query(query)
      return none if sanitized.blank?

      joins("INNER JOIN search_records_fts ON search_records_fts.rowid = search_records.id")
        .where("search_records_fts MATCH ?", sanitized)
        .select(
          "search_records.*",
          "highlight(search_records_fts, 0, '<mark>', '</mark>') AS highlighted_title",
          "snippet(search_records_fts, 1, '<mark>', '</mark>', '...', 20) AS highlighted_content"
        )
        .order(Arel.sql("rank"))
    end

    private

    def sync_fts(record)
      connection.execute(<<-SQL)
        INSERT OR REPLACE INTO search_records_fts(rowid, title, content)
        VALUES (#{record.id}, #{connection.quote(record.title)}, #{connection.quote(record.content)})
      SQL
    end

    def remove_from_fts(id)
      connection.execute("DELETE FROM search_records_fts WHERE rowid = #{id}")
    end

    def sanitize_query(query)
      query.to_s.gsub(/[^\w\s"]/, " ").squish
    end
  end
end
```

---

## Step 3: Creare il Concern Searchable

**File**: `app/models/concerns/searchable.rb`

```ruby
module Searchable
  extend ActiveSupport::Concern

  included do
    after_create_commit :create_in_search_index
    after_update_commit :update_in_search_index
    after_destroy_commit :remove_from_search_index
  end

  def create_in_search_index
    Search::Record.upsert!(self, search_record_attributes)
  end

  def update_in_search_index
    Search::Record.upsert!(self, search_record_attributes)
  end

  def remove_from_search_index
    Search::Record.remove!(self)
  end

  # Override in model
  def search_record_attributes
    raise NotImplementedError
  end
end
```

---

## Step 4: Modificare Pagina

**File**: `app/models/pagina.rb` (aggiungere all'inizio della classe)

```ruby
class Pagina < ApplicationRecord
  include Searchable

  # ... existing code ...

  def search_record_attributes
    {
      pagina_id: id,
      disciplina_id: disciplina_id,
      volume_id: disciplina&.volume_id,
      title: titolo,
      content: [
        sottotitolo,
        "Pagina #{numero}",
        disciplina&.nome,
        disciplina&.volume&.nome,
        disciplina&.volume&.corso&.nome
      ].compact.join(" ")
    }
  end
end
```

---

## Step 5: Modificare Esercizio

**File**: `app/models/esercizio.rb` (aggiungere dopo `include Shareable`)

```ruby
class Esercizio < ApplicationRecord
  include Shareable
  include Searchable

  # ... existing code ...

  def search_record_attributes
    {
      pagina_id: nil,
      disciplina_id: nil,
      volume_id: nil,
      title: title,
      content: [
        description,
        category,
        tags&.join(" ")
      ].compact.join(" ")
    }
  end
end
```

---

## Step 6: Creare il Controller

**File**: `app/controllers/searches_controller.rb`

```ruby
class SearchesController < ApplicationController
  def show
    @query = params[:q].to_s.strip
    @results = Search::Record.search(@query).limit(50) if @query.present?
  end
end
```

---

## Step 7: Aggiungere la Route

**File**: `config/routes.rb` (aggiungere dopo la riga `root`)

```ruby
resource :search, only: :show
```

---

## Step 8: Creare la View

**File**: `app/views/searches/show.html.erb`

```erb
<div class="container mx-auto p-4 max-w-4xl">
  <h1 class="text-2xl font-bold mb-6">Cerca</h1>

  <%= form_with url: search_path, method: :get, class: "mb-8" do %>
    <div class="flex gap-2">
      <%= text_field_tag :q, @query,
          placeholder: "Cerca pagine ed esercizi...",
          class: "flex-1 border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500",
          autofocus: true %>
      <%= submit_tag "Cerca", class: "bg-blue-500 hover:bg-blue-600 text-white px-6 py-2 rounded-lg cursor-pointer" %>
    </div>
  <% end %>

  <% if @query.present? %>
    <p class="text-gray-600 mb-4">
      <%= @results&.size || 0 %> risultat<%= (@results&.size || 0) == 1 ? 'o' : 'i' %>
      per "<strong><%= @query %></strong>"
    </p>

    <div class="space-y-3">
      <% @results&.each do |result| %>
        <% if result.searchable_type == "Pagina" && result.pagina %>
          <%= link_to pagina_path(result.pagina.slug),
              class: "block p-4 border border-gray-200 rounded-lg hover:bg-gray-50 hover:border-blue-300 transition" do %>
            <div class="flex items-center gap-2 mb-1">
              <span class="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded">Pagina</span>
            </div>
            <h3 class="font-semibold text-lg"><%= raw result.highlighted_title %></h3>
            <p class="text-sm text-gray-600 mt-1"><%= raw result.highlighted_content %></p>
            <p class="text-xs text-gray-400 mt-2">
              <%= result.pagina.disciplina.volume.corso.nome %> &rsaquo;
              <%= result.pagina.disciplina.volume.nome %> &rsaquo;
              <%= result.pagina.disciplina.nome %>
            </p>
          <% end %>
        <% elsif result.searchable_type == "Esercizio" %>
          <% esercizio = result.searchable %>
          <%= link_to public_esercizio_path(esercizio.share_token),
              class: "block p-4 border border-gray-200 rounded-lg hover:bg-gray-50 hover:border-green-300 transition" do %>
            <div class="flex items-center gap-2 mb-1">
              <span class="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded">Esercizio</span>
              <% if esercizio.category.present? %>
                <span class="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded"><%= esercizio.category %></span>
              <% end %>
            </div>
            <h3 class="font-semibold text-lg"><%= raw result.highlighted_title %></h3>
            <p class="text-sm text-gray-600 mt-1"><%= raw result.highlighted_content %></p>
            <% if esercizio.tags.present? %>
              <div class="flex gap-1 mt-2">
                <% esercizio.tags.each do |tag| %>
                  <span class="text-xs bg-gray-100 text-gray-500 px-2 py-0.5 rounded"><%= tag %></span>
                <% end %>
              </div>
            <% end %>
          <% end %>
        <% end %>
      <% end %>
    </div>
  <% else %>
    <div class="text-center text-gray-500 py-12">
      <p>Inserisci un termine di ricerca per trovare pagine ed esercizi.</p>
    </div>
  <% end %>
</div>
```

---

## Step 9: Creare il Rake Task

**File**: `lib/tasks/search.rake`

```ruby
namespace :search do
  desc "Rebuild search index for all pages and exercises"
  task rebuild: :environment do
    puts "Pulizia indice esistente..."
    Search::Record.delete_all
    ActiveRecord::Base.connection.execute("DELETE FROM search_records_fts")

    print "Indicizzando pagine"
    Pagina.find_each do |pagina|
      pagina.create_in_search_index
      print "."
    end
    puts " #{Pagina.count} pagine indicizzate"

    print "Indicizzando esercizi"
    Esercizio.find_each do |esercizio|
      esercizio.create_in_search_index
      print "."
    end
    puts " #{Esercizio.count} esercizi indicizzati"

    puts "Completato!"
  end
end
```

---

## File da Creare/Modificare

| File | Azione |
|------|--------|
| `db/migrate/XXXXXX_create_search_records.rb` | Creare |
| `app/models/search/record.rb` | Creare (+ directory `app/models/search/`) |
| `app/models/concerns/searchable.rb` | Creare |
| `app/models/pagina.rb` | Modificare (aggiungere `include Searchable` + metodo) |
| `app/models/esercizio.rb` | Modificare (aggiungere `include Searchable` + metodo) |
| `app/controllers/searches_controller.rb` | Creare |
| `app/views/searches/show.html.erb` | Creare (+ directory `app/views/searches/`) |
| `config/routes.rb` | Modificare (aggiungere `resource :search`) |
| `lib/tasks/search.rake` | Creare |

---

## Comandi da Eseguire

```bash
# 1. Crea la migration
bin/rails generate migration CreateSearchRecords

# 2. Copia il contenuto della migration dallo Step 1

# 3. Crea le directory necessarie
mkdir -p app/models/search
mkdir -p app/views/searches

# 4. Crea i file come indicato sopra

# 5. Esegui la migration
bin/rails db:migrate

# 6. Ricostruisci l'indice di ricerca
bin/rails search:rebuild

# 7. Avvia il server
bin/dev
```

Poi visita: `http://localhost:3000/search?q=grammatica`

---

## Note Tecniche

### Come funziona FTS5

1. **Tabella normale** (`search_records`): contiene i dati denormalizzati e le relazioni
2. **Tabella virtuale FTS5** (`search_records_fts`): contiene solo `title` e `content` per la ricerca full-text
3. **Sincronizzazione**: i callback `after_*_commit` mantengono le due tabelle sincronizzate
4. **Porter stemmer**: riduce le parole alla loro radice (es. "grammatica" -> "grammat") per match migliori

### Funzioni FTS5 usate

- `MATCH`: esegue la ricerca full-text
- `highlight()`: evidenzia i termini trovati con `<mark>`
- `snippet()`: estrae un frammento di testo con contesto (20 parole)
- `rank`: ordina per rilevanza (score BM25)
