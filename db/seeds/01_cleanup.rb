# Pulizia database esistente
puts "🧹 Pulizia dati esistenti..."

# Disabilita foreign key constraints per SQLite durante la pulizia
ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")

# Prima elimina le tabelle dipendenti (con foreign keys)
SearchRecord.destroy_all if defined?(SearchRecord)
EsercizioAttempt.destroy_all if defined?(EsercizioAttempt)
Esercizio.destroy_all if defined?(Esercizio)
EsercizioTemplate.destroy_all if defined?(EsercizioTemplate)

# Poi elimina le tabelle principali nell'ordine corretto
Pagina.destroy_all
Disciplina.destroy_all
Volume.destroy_all
Corso.destroy_all

# Riabilita foreign key constraints
ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON")
