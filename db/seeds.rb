# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Inizio seed del database..."

# Carica tutti i file seed dalla directory db/seeds in ordine alfabetico
# I file sono numerati per garantire l'ordine corretto di esecuzione
seed_files = Dir.glob(Rails.root.join("db", "seeds", "*.rb")).sort

if seed_files.empty?
  puts "⚠️  Nessun file seed trovato in db/seeds/"
else
  seed_files.each do |file|
    puts "\n📄 Caricamento: #{File.basename(file)}"
    load file
  end
end

puts "\n✅ Tutti i seed sono stati caricati!"
