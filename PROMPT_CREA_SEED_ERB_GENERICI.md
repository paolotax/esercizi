# Prompt: Creazione Seed e ERB Generici per Nuovo Libro

Questo prompt descrive il processo per creare automaticamente seed generico e file ERB per tutte le pagine mancanti di un libro, utilizzando il layout della prima pagina come template.

## Contesto

Quando si ha un libro con:
- Directory immagini già create in `app/assets/images/{prefix}/p001/`, `p002/`, etc.
- Alcune pagine già definite nel seed con ERB personalizzati
- Necessità di creare pagine generiche per tutte le pagine mancanti

## Informazioni Richieste

Prima di iniziare, raccogliere:

1. **Identificatori del libro**:
   - `corso_codice`: codice del corso (es: "bus", "nvl", "nvi")
   - `volume_classe`: classe del volume (es: 3, 4, 5)
   - `disciplina_codice`: codice della disciplina (es: "mat", "gram", "lettgr")
   - `prefix`: prefisso per le directory immagini (es: "bus3_mat", "nvl5_gram")

2. **Pagine esistenti**: elenco dei numeri di pagina già definiti nel seed (es: [25, 26, 32, 34, 35, 74, 75, 76, 77, 78, 144])

3. **Range pagine**: numero minimo e massimo di pagine (es: 1-192)

4. **Colore tema**: colore per i controlli esercizio (es: "blue", "purple", "orange")

5. **Template pagina**: path del file ERB da usare come template (es: `app/views/exercises/bus3_mat_p001.html.erb`)

## Processo

### 1. Verifica Struttura

Verificare che:
- Le directory immagini esistano: `app/assets/images/{prefix}/p001/`, `p002/`, etc.
- Il corso, volume e disciplina siano già definiti nel seed
- Esista almeno un file ERB di esempio (p001 o prima pagina disponibile)

### 2. Creazione Seed Generico

Aggiungere al file `db/seeds.rb` dopo la sezione delle pagine esistenti:

```ruby
# Pagine generiche per {prefix} (p{min}-p{max}, escludendo quelle già definite)
existing_pages = [25, 26, 32, 34, 35, 74, 75, 76, 77, 78, 144]  # SOSTITUIRE con pagine esistenti
generic_pages_created = 0

({min}..{max}).each do |numero|
  next if existing_pages.include?(numero)
  
  numero_str = numero.to_s.rjust(3, '0')
  slug = "{prefix}_p#{numero_str}"
  view_template = "{prefix}_p#{numero_str}"
  
  # Usa find_or_create_by per rendere il seed idempotente
  {disciplina_variabile}.pagine.find_or_create_by(slug: slug) do |pagina|
    pagina.numero = numero
    pagina.titolo = "Pagina #{numero}"
    pagina.view_template = view_template
  end
  
  generic_pages_created += 1
end

puts "  ✓ Aggiunte #{generic_pages_created} pagine generiche"
```

**Sostituzioni**:
- `{prefix}`: prefisso del libro (es: "bus3_mat")
- `{min}`: numero pagina minimo (es: 1)
- `{max}`: numero pagina massimo (es: 192)
- `{disciplina_variabile}`: variabile della disciplina nel seed (es: `bus_matematica`)
- `existing_pages`: array con i numeri delle pagine già esistenti

### 3. Template ERB Standard

Il template standard per le pagine generiche è:

```erb
<% content_for :titolo, "#{@pagina.titolo} - #{@pagina.numero}" %>

<div class="max-w-7xl mx-auto p-6 bg-gradient-to-b from-blue-50 to-white" data-controller="exercise-checker">
  <!-- Header -->
  <%= render 'shared/page_header', pagina: @pagina %>

  <!-- Immagine della pagina -->
  <%= render 'shared/page_image', pagina: @pagina %>

  <!-- Footer con controlli -->
  <%= render 'shared/exercise_controls', color: '{colore}' %>
</div>
```

**Sostituzioni**:
- `{colore}`: colore tema (es: "blue", "purple", "orange")

**Nota**: Il partial `shared/page_image` genera automaticamente il percorso dell'immagine dal slug della pagina (es: `bus3_mat/p001/page.png`).

### 4. Creazione File ERB

Creare uno script per generare tutti i file ERB mancanti:

```bash
#!/bin/bash

# Configurazione
PREFIX="{prefix}"  # es: "bus3_mat"
EXISTING=(25 26 32 34 35 74 75 76 77 78 144)  # Pagine esistenti
MIN=1
MAX=192
COLOR="{colore}"  # es: "blue"

# Template ERB
TEMPLATE='<% content_for :titolo, "#{@pagina.titolo} - #{@pagina.numero}" %>

<div class="max-w-7xl mx-auto p-6 bg-gradient-to-b from-blue-50 to-white" data-controller="exercise-checker">
  <!-- Header -->
  <%= render '\''shared/page_header'\'', pagina: @pagina %>

  <!-- Immagine della pagina -->
  <%= render '\''shared/page_image'\'', pagina: @pagina %>

  <!-- Footer con controlli -->
  <%= render '\''shared/exercise_controls'\'', color: '\''{COLOR}'\'' %>
</div>'

count=0

for num in $(seq $MIN $MAX); do
  # Controlla se la pagina è già esistente
  skip=false
  for e in "${EXISTING[@]}"; do
    if [ "$num" -eq "$e" ]; then
      skip=true
      break
    fi
  done
  
  if [ "$skip" = true ]; then
    continue
  fi
  
  # Controlla se il file ERB esiste già
  num_str=$(printf "%03d" $num)
  filename="app/views/exercises/${PREFIX}_p${num_str}.html.erb"
  
  if [ -f "$filename" ]; then
    echo "  [SKIP] $filename già esistente"
    continue
  fi
  
  # Crea il file ERB
  echo "$TEMPLATE" | sed "s/{COLOR}/$COLOR/g" > "$filename"
  count=$((count + 1))
done

echo "Creati $count file ERB"
```

**Oppure usando Python**:

```python
import os

# Configurazione
PREFIX = "{prefix}"  # es: "bus3_mat"
EXISTING = [25, 26, 32, 34, 35, 74, 75, 76, 77, 78, 144]  # Pagine esistenti
MIN_PAGE = 1
MAX_PAGE = 192
COLOR = "{colore}"  # es: "blue"

TEMPLATE = '''<% content_for :titolo, "#{@pagina.titolo} - #{@pagina.numero}" %>

<div class="max-w-7xl mx-auto p-6 bg-gradient-to-b from-blue-50 to-white" data-controller="exercise-checker">
  <!-- Header -->
  <%= render 'shared/page_header', pagina: @pagina %>

  <!-- Immagine della pagina -->
  <%= render 'shared/page_image', pagina: @pagina %>

  <!-- Footer con controlli -->
  <%= render 'shared/exercise_controls', color: '{COLOR}' %>
</div>'''

count = 0

for num in range(MIN_PAGE, MAX_PAGE + 1):
    if num in EXISTING:
        continue
    
    num_str = f"{num:03d}"
    filename = f"app/views/exercises/{PREFIX}_p{num_str}.html.erb"
    
    if os.path.exists(filename):
        print(f"  [SKIP] {filename} già esistente")
        continue
    
    with open(filename, 'w') as f:
        f.write(TEMPLATE.replace('{COLOR}', COLOR))
    count += 1

print(f"Creati {count} file ERB")
```

### 5. Verifica

Dopo la creazione, verificare:

1. **Seed**: Eseguire `rails db:seed` e verificare che non ci siano errori
2. **File ERB**: Contare i file creati:
   ```bash
   ls -1 app/views/exercises/{prefix}_p*.html.erb | wc -l
   ```
3. **Immagini**: Verificare che le directory immagini esistano:
   ```bash
   ls -d app/assets/images/{prefix}/p* | wc -l
   ```
4. **Test**: Aprire una pagina generica nel browser per verificare che funzioni

## Esempio Completo: bus3_mat

**Configurazione**:
- `prefix`: "bus3_mat"
- `existing_pages`: [25, 26, 32, 34, 35, 74, 75, 76, 77, 78, 144]
- `range`: 1-192
- `color`: "blue"
- `disciplina_variabile`: `bus_matematica`

**Seed** (da aggiungere dopo riga 326 in `db/seeds.rb`):
```ruby
# Pagine generiche per bus3_mat (p001-p192, escludendo le 11 già definite sopra)
existing_pages = [25, 26, 32, 34, 35, 74, 75, 76, 77, 78, 144]
generic_pages_created = 0

(1..192).each do |numero|
  next if existing_pages.include?(numero)
  
  numero_str = numero.to_s.rjust(3, '0')
  slug = "bus3_mat_p#{numero_str}"
  view_template = "bus3_mat_p#{numero_str}"
  
  bus_matematica.pagine.find_or_create_by(slug: slug) do |pagina|
    pagina.numero = numero
    pagina.titolo = "Pagina #{numero}"
    pagina.view_template = view_template
  end
  
  generic_pages_created += 1
end

puts "  ✓ Aggiunte #{generic_pages_created} pagine generiche"
```

**Template ERB** (usato per tutti i file):
```erb
<% content_for :titolo, "#{@pagina.titolo} - #{@pagina.numero}" %>

<div class="max-w-7xl mx-auto p-6 bg-gradient-to-b from-blue-50 to-white" data-controller="exercise-checker">
  <!-- Header -->
  <%= render 'shared/page_header', pagina: @pagina %>

  <!-- Immagine della pagina -->
  <%= render 'shared/page_image', pagina: @pagina %>

  <!-- Footer con controlli -->
  <%= render 'shared/exercise_controls', color: 'blue' %>
</div>
```

## Note Importanti

1. **Idempotenza**: Il seed usa `find_or_create_by` per evitare duplicati
2. **Non sovrascrivere**: Gli script controllano se i file ERB esistono già prima di crearli
3. **Partial riutilizzabili**: 
   - `shared/page_header`: genera header automaticamente da `@pagina`
   - `shared/page_image`: genera percorso immagine automaticamente da `@pagina.slug`
4. **Convenzioni naming**:
   - Slug: `{prefix}_p{numero}` (es: "bus3_mat_p001")
   - View template: stesso del slug
   - Directory immagini: `app/assets/images/{prefix}/p{numero}/page.png`

## Troubleshooting

- **Errore "Pagina già esistente"**: Verificare che `existing_pages` includa tutte le pagine già definite
- **Immagini non trovate**: Verificare che le directory esistano in `app/assets/images/{prefix}/`
- **ERB non renderizzati**: Verificare che `view_template` nel seed corrisponda al nome del file ERB

