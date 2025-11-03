# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Inizio seed del database..."

# Pulizia database esistente
puts "🧹 Pulizia dati esistenti..."
Pagina.destroy_all
Disciplina.destroy_all
Volume.destroy_all
Corso.destroy_all

# 1. CANTA E IMPARA 1
puts "\n📚 Creazione corso: Canta e Impara"
canta_impara = Corso.create!(
  nome: "Canta e Impara",
  codice: "cai",
  descrizione: "Metodo di lettura per la scuola primaria"
)

cai_volume1 = canta_impara.volumi.create!(
  nome: "Canta e Impara 1",
  classe: 1,
  posizione: 1
)

cai_metodo = cai_volume1.discipline.create!(
  nome: "Metodo",
  codice: "met",
  colore: "#F97316"
)

[
  { numero: 8, titolo: "Uguali o Diversi?", slug: "pag008", view_template: "pag008" },
  { numero: 10, titolo: "Come Inizia?", slug: "pag010", view_template: "pag010" },
  { numero: 10, titolo: "Come Inizia? (bis)", slug: "pag010gen", view_template: "pag010gen" },
  { numero: 22, titolo: "Lettera A - Scrivo", slug: "pag022", view_template: "pag022" },
  { numero: 23, titolo: "Lettera A - Leggo", slug: "pag023", view_template: "pag023" },
  { numero: 41, titolo: "Lettera O - Leggo", slug: "pag041", view_template: "pag041" },
  { numero: 43, titolo: "Lettera U - Scopro il suono", slug: "pag043", view_template: "pag043" },
  { numero: 50, titolo: "Esercizio pagina 50", slug: "pag050", view_template: "pag050" },
  { numero: 51, titolo: "Esercizio pagina 51", slug: "pag051", view_template: "pag051" },
  { numero: 167, titolo: "Esercizio pagina 167", slug: "pag167", view_template: "pag167" }
].each do |pagina_data|
  cai_metodo.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{cai_volume1.nome}' con #{cai_metodo.pagine.count} pagine"

# 2. NUOVO VIVA LEGGERE 4
puts "\n📚 Creazione corso: Nuovo Viva Leggere"
nvl = Corso.create!(
  nome: "Nuovo Viva Leggere",
  codice: "nvl",
  descrizione: "Corso di italiano per la scuola primaria"
)

nvl_volume4 = nvl.volumi.create!(
  nome: "Nuovo Viva Leggere 4",
  classe: 4,
  posizione: 4
)

nvl_grammatica = nvl_volume4.discipline.create!(
  nome: "Grammatica",
  codice: "gr",
  colore: "#EC4899"
)

[
  { numero: 8, titolo: "La lettera C", slug: "nvl_4_gr_pag008", view_template: "nvl_4_gr_pag008" },
  { numero: 9, titolo: "La lettera C - CE/CIE", slug: "nvl_4_gr_pag009", view_template: "nvl_4_gr_pag009" },
  { numero: 14, titolo: "Il gruppo GL", slug: "nvl_4_gr_pag014", view_template: "nvl_4_gr_pag014" },
  { numero: 15, titolo: "GN o NI?", slug: "nvl_4_gr_pag015", view_template: "nvl_4_gr_pag015" }
].each do |pagina_data|
  nvl_grammatica.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{nvl_volume4.nome}' con #{nvl_grammatica.pagine.count} pagine"

# 3. BANDA DEL BUS 3
puts "\n📚 Creazione corso: Banda del BUS"
bus = Corso.create!(
  nome: "Banda del BUS",
  codice: "bus",
  descrizione: "Corso di matematica per la scuola primaria"
)

bus_volume3 = bus.volumi.create!(
  nome: "BUS 3",
  classe: 3,
  posizione: 3
)

bus_matematica = bus_volume3.discipline.create!(
  nome: "Matematica",
  codice: "mat",
  colore: "#3B82F6"
)

[
  { numero: 25, titolo: "Addizioni in colonna", slug: "bus3_mat_p025", view_template: "bus3_mat_p025" },
  { numero: 26, titolo: "Addizioni con il cambio", slug: "bus3_mat_p026", view_template: "bus3_mat_p026" },
  { numero: 144, titolo: "Proprietà dell'Addizione", slug: "bus3_mat_p144", view_template: "bus3_mat_p144" }
].each do |pagina_data|
  bus_matematica.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{bus_volume3.nome}' con #{bus_matematica.pagine.count} pagine"

# 4. NUOVO VIVA IMPARARE 4
puts "\n📚 Creazione corso: Nuovo Viva Imparare"
nvi = Corso.create!(
  nome: "Nuovo Viva Imparare",
  codice: "nvi",
  descrizione: "Sussidiario delle discipline per la scuola primaria"
)

nvi_volume4 = nvi.volumi.create!(
  nome: "Nuovo Viva Imparare 4",
  classe: 4,
  posizione: 4
)

# Matematica
nvi_matematica = nvi_volume4.discipline.create!(
  nome: "Matematica",
  codice: "mat",
  colore: "#A855F7"
)

[
  { numero: 5, titolo: "La Linea dei Numeri", slug: "sussi_pag_5", view_template: "sussi_pag_5" },
  { numero: 14, titolo: "Sistema di Numerazione", slug: "sussi_pag_14", view_template: "sussi_pag_14" }
].each do |pagina_data|
  nvi_matematica.pagine.create!(pagina_data)
end

# Storia
nvi_storia = nvi_volume4.discipline.create!(
  nome: "Storia",
  codice: "sto",
  colore: "#06B6D4"
)

[
  { numero: 154, titolo: "Le Conoscenze dei Babilonesi", slug: "nvi4_sto_p154", view_template: "nvi4_sto_p154" },
  { numero: 155, titolo: "Gli Ittiti", slug: "nvi4_sto_p155", view_template: "nvi4_sto_p155" }
].each do |pagina_data|
  nvi_storia.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{nvi_volume4.nome}' con #{nvi_matematica.pagine.count} pagine di matematica e #{nvi_storia.pagine.count} pagine di storia"

# Riepilogo finale
puts "\n✅ Seed completato!"
puts "\n📊 Riepilogo:"
puts "   - #{Corso.count} corsi"
puts "   - #{Volume.count} volumi"
puts "   - #{Disciplina.count} discipline"
puts "   - #{Pagina.count} pagine"

puts "\n🚀 Puoi visitare http://localhost:3000 per vedere i corsi!"
