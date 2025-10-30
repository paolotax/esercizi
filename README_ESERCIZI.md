# Esercizi Fonetici - Rails Application

Applicazione Rails 8.1.0 per esercizi fonetici interattivi **senza Tailwind CSS**.

## Caratteristiche

- **Framework**: Rails 8.1.0
- **Ruby**: 3.2.2
- **Database**: SQLite3
- **CSS**: CSS puro (NO Tailwind) - tutte le classi Tailwind sono state replicate in CSS vanilla
- **JavaScript**: Stimulus.js per l'interattività
- **Audio**: Supporto completo per riproduzione audio con HTML5

## Struttura del Progetto

### Controllers
- `app/controllers/exercises_controller.rb` - Gestisce le 4 pagine di esercizi

### Views
Le view utilizzano classi CSS che replicano esattamente Tailwind ma sono implementate in CSS puro:

1. **phonetic_exercise.html.erb** - Primo esercizio fonetico con 4 gruppi (Luna, Balena, Albero, Telefono)
2. **phonetic_exercise2.html.erb** - Secondo esercizio fonetico con 4 gruppi (Mela, Sole, Pane, Rosa)
3. **pag50.html.erb** - Esercizio sulle vocali con conteggio parole
4. **pag51.html.erb** - Esercizio "Ho Imparato" con completamento parole

### Stimulus Controllers (JavaScript)
- `app/javascript/controllers/audio_player_controller.js` - Gestisce la riproduzione audio
- `app/javascript/controllers/exercise_checker_controller.js` - Verifica le risposte
- `app/javascript/controllers/exercise_group_controller.js` - Gestisce i gruppi di domande

### CSS
- `app/assets/stylesheets/application.css` - **CSS PURO** che replica esattamente tutte le classi Tailwind utilizzate nelle view

### Audio Files
- `public/audios/exercises/*.mp3` - 39 file audio per tutte le parole degli esercizi

## Routes

```ruby
root "exercises#phonetic_exercise"

get 'exercises/phonetic'   # Primo esercizio fonetico
get 'exercises/phonetic2'  # Secondo esercizio fonetico
get 'exercises/pag50'      # Esercizio vocali
get 'exercises/pag51'      # Esercizio "Ho Imparato"
```

## Come Avviare

```bash
cd /home/paolotax/rails_2023/esercizi

# Installare le dipendenze
bundle install

# Avviare il server
bin/rails server

# Oppure specificare una porta
bin/rails server -p 3001
```

L'applicazione sarà disponibile su http://localhost:3000 (o la porta specificata).

## Funzionalità Interattive

### Audio
- Click sull'emoji per ascoltare la pronuncia
- Utilizza HTML5 Audio API
- Event.stopPropagation() per separare audio da selezione risposta

### Esercizi
- Click sulla checkbox per selezionare la risposta
- Bottone "Controlla le Risposte" per verificare
- Feedback visivo con segni di spunta (✓) e croci (✗)
- Colori differenziati per ogni esercizio

### Responsive
- Layout responsive con breakpoint a 768px
- Grid che si adatta da 2 colonne a 1 colonna su mobile
- Emoji scalabili e ben spaziati

## Classi CSS Implementate

Tutte le seguenti classi Tailwind sono state reimplementate in CSS puro:

- **Layout**: flex, grid, hidden, space-y-*, gap-*
- **Sizing**: w-*, h-*, max-w-*, min-h-*
- **Spacing**: p-*, px-*, py-*, m-*, mx-*, my-*
- **Colors**: bg-*, text-*, border-*
- **Typography**: text-*, font-*
- **Borders**: border-*, rounded-*, divide-*
- **Effects**: shadow-*, transition, hover:*
- **Backgrounds**: Gradienti con variabili CSS
- **Transform**: scale, hover:scale-*

## Differenze dal Progetto Originale

1. **NO Tailwind CSS** - Tutto in CSS puro
2. **Stesso aspetto visivo** - Le view sono identiche
3. **Stesse funzionalità** - Tutti i controller Stimulus funzionano ugualmente
4. **Layout pulito** - Rimosso wrapper `<main>` dal layout

## File Audio Richiesti

I seguenti 39 file MP3 devono essere presenti in `public/audios/exercises/`:

**Esercizio 1**: luna.mp3, lumaca.mp3, ape.mp3, matita.mp3, balena.mp3, sole.mp3, nuvola.mp3, banana.mp3, albero.mp3, mostro.mp3, arco.mp3, lingua.mp3, telefono.mp3, topo.mp3, occhiali.mp3, cane.mp3

**Esercizio 2**: mela.mp3, gatto.mp3, mare.mp3, tigre.mp3, stella.mp3, fiore.mp3, casa.mp3, pane.mp3, palla.mp3, treno.mp3, leone.mp3, rosa.mp3, drago.mp3, radio.mp3, gelato.mp3

**Altri esercizi**: ali.mp3, lupo.mp3, uva.mp3, topi.mp3, vela.mp3, uno.mp3, ala.mp3, onda.mp3, auto.mp3, isola.mp3, elica.mp3

## Note Tecniche

- Le view **NON sono state modificate** - usano le stesse classi
- Il CSS replica esattamente il comportamento di Tailwind
- Gradienti implementati con variabili CSS (`--tw-gradient-from`, `--tw-gradient-to`)
- Hover states e transitions funzionano identicamente
- Responsive breakpoints implementati con media queries

## Testing

Per verificare che le pagine abbiano lo stesso aspetto:

1. Aprire http://localhost:3000 (dovrebbe mostrare phonetic_exercise)
2. Navigare tra le 4 pagine
3. Testare l'audio cliccando sugli emoji
4. Testare le checkbox e il bottone "Controlla Risposte"
5. Ridimensionare il browser per testare responsive

Tutte le view dovrebbero apparire identiche al progetto originale con Tailwind.
