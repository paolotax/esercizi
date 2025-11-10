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

# 2b. NUOVO VIVA LEGGERE 5
nvl_volume5 = nvl.volumi.create!(
  nome: "Nuovo Viva Leggere 5",
  classe: 5,
  posizione: 5
)

nvl5_grammatica = nvl_volume5.discipline.create!(
  nome: "Grammatica",
  codice: "gr",
  colore: "#EC4899"
)

[
  { numero: 8, titolo: "Viva il ripasso!", slug: "nvl5_gr_p008", view_template: "nvl5_gr_p008" },
  { numero: 9, titolo: "Ricordi il plurale di -CIA e -GIA?", slug: "nvl5_gr_p009", view_template: "nvl5_gr_p009" },
  { numero: 10, titolo: "La lettera H", slug: "nvl5_gr_p010", view_template: "nvl5_gr_p010" },
  { numero: 11, titolo: "LO/L'HO, LA/L'HA e altre forme", slug: "nvl5_gr_p011", view_template: "nvl5_gr_p011" },
  { numero: 12, titolo: "La divisione in sillabe", slug: "nvl5_gr_p012", view_template: "nvl5_gr_p012" },
  { numero: 13, titolo: "La lettera maiuscola", slug: "nvl5_gr_p013", view_template: "nvl5_gr_p013" },
  { numero: 14, titolo: "Monosillabi e accento", slug: "nvl5_gram_p014", view_template: "nvl5_gram_p014" },
  { numero: 15, titolo: "Monosillabi con e senza accento", slug: "nvl5_gram_p015", view_template: "nvl5_gram_p015" },
  { numero: 16, titolo: "L'elisione", slug: "nvl5_gram_p016", view_template: "nvl5_gram_p016" },
  { numero: 17, titolo: "Il troncamento", slug: "nvl5_gram_p017", view_template: "nvl5_gram_p017" },
  { numero: 18, titolo: "La punteggiatura", slug: "nvl5_gram_p018", view_template: "nvl5_gram_p018" },
  { numero: 19, titolo: "Discorso diretto e indiretto", slug: "nvl5_gram_p019", view_template: "nvl5_gram_p019" },
  { numero: 20, titolo: "Verifica - L'ortografia", slug: "nvl5_gram_p020", view_template: "nvl5_gram_p020" },
  { numero: 21, titolo: "Verifica - Ortografia e accenti", slug: "nvl5_gram_p021", view_template: "nvl5_gram_p021" },
  { numero: 22, titolo: "Parole al centro - Lessico", slug: "nvl5_gram_p022", view_template: "nvl5_gram_p022" },
  { numero: 23, titolo: "Parole al centro - Lessico e parole composte", slug: "nvl5_gram_p023", view_template: "nvl5_gram_p023" },
  { numero: 24, titolo: "L'origine della lingua italiana", slug: "nvl5_gram_p024", view_template: "nvl5_gram_p024" },
  { numero: 25, titolo: "I dialetti", slug: "nvl5_gram_p025", view_template: "nvl5_gram_p025" },
  { numero: 26, titolo: "La lingua nel tempo", slug: "nvl5_gram_p026", view_template: "nvl5_gram_p026" },
  { numero: 27, titolo: "Le parole in prestito", slug: "nvl5_gram_p027", view_template: "nvl5_gram_p027" },
  { numero: 28, titolo: "Sinonimi e contrari", slug: "nvl5_gram_p028", view_template: "nvl5_gram_p028" },
  { numero: 29, titolo: "Sinonimi e contrari - esercizi", slug: "nvl5_gram_p029", view_template: "nvl5_gram_p029" },
  { numero: 30, titolo: "Le sfumature dei sinonimi", slug: "nvl5_gram_p030", view_template: "nvl5_gram_p030" },
  { numero: 31, titolo: "Parole… in scala!", slug: "nvl5_gram_p031", view_template: "nvl5_gram_p031" },
  { numero: 32, titolo: "Le parole polisemiche", slug: "nvl5_gram_p032", view_template: "nvl5_gram_p032" },
  { numero: 33, titolo: "Gli omonimi", slug: "nvl5_gram_p033", view_template: "nvl5_gram_p033" },
  { numero: 34, titolo: "Il linguaggio settoriale", slug: "nvl5_gram_p034", view_template: "nvl5_gram_p034" },
  { numero: 35, titolo: "Linguaggio settoriale – esercizi", slug: "nvl5_gram_p035", view_template: "nvl5_gram_p035" },
  { numero: 36, titolo: "Il linguaggio figurato", slug: "nvl5_gram_p036", view_template: "nvl5_gram_p036" },
  { numero: 37, titolo: "Il linguaggio figurato – esercizi", slug: "nvl5_gram_p037", view_template: "nvl5_gram_p037" },
  { numero: 38, titolo: "VERIFICA – Il lessico (Parte 1)", slug: "nvl5_gram_p038", view_template: "nvl5_gram_p038" },
  { numero: 39, titolo: "VERIFICA – Il lessico (Parte 2)", slug: "nvl5_gram_p039", view_template: "nvl5_gram_p039" },
  { numero: 40, titolo: "Parole al centro – Morfologia", slug: "nvl5_gram_p040", view_template: "nvl5_gram_p040" },
  { numero: 41, titolo: "Parole al centro – Morfologia", slug: "nvl5_gram_p041", view_template: "nvl5_gram_p041" },
  { numero: 42, titolo: "Il genere dei nomi (Parte 1)", slug: "nvl5_gram_p042", view_template: "nvl5_gram_p042" },
  { numero: 43, titolo: "Il genere dei nomi (Parte 2)", slug: "nvl5_gram_p043", view_template: "nvl5_gram_p043" },
  { numero: 44, titolo: "Il numero dei nomi (Parte 1)", slug: "nvl5_gram_p044", view_template: "nvl5_gram_p044" },
  { numero: 45, titolo: "Il numero dei nomi (Parte 2)", slug: "nvl5_gram_p045", view_template: "nvl5_gram_p045" },
  { numero: 46, titolo: "Il significato dei nomi", slug: "nvl5_gram_p046", view_template: "nvl5_gram_p046" },
  { numero: 47, titolo: "La struttura dei nomi", slug: "nvl5_gram_p047", view_template: "nvl5_gram_p047" },
  { numero: 48, titolo: "Gli articoli", slug: "nvl5_gram_p048", view_template: "nvl5_gram_p048" },
  { numero: 49, titolo: "Gli articoli – esercizi", slug: "nvl5_gram_p049", view_template: "nvl5_gram_p049" },
  { numero: 50, titolo: "VERIFICA – Nomi e articoli", slug: "nvl5_gram_p050", view_template: "nvl5_gram_p050" },
  { numero: 51, titolo: "VERIFICA – Nomi e articoli (Tabella)", slug: "nvl5_gram_p051", view_template: "nvl5_gram_p051" },
  { numero: 52, titolo: "Gli aggettivi qualificativi", slug: "nvl5_gram_p052", view_template: "nvl5_gram_p052" },
  { numero: 53, titolo: "Gli aggettivi qualificativi – esercizi", slug: "nvl5_gram_p053", view_template: "nvl5_gram_p053" },
  { numero: 54, titolo: "I pronomi personali", slug: "nvl5_gram_p054", view_template: "nvl5_gram_p054" },
  { numero: 55, titolo: "I pronomi personali – particelle", slug: "nvl5_gram_p055", view_template: "nvl5_gram_p055" }
].each do |pagina_data|
  nvl5_grammatica.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{nvl_volume5.nome}' con #{nvl5_grammatica.pagine.count} pagine"

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
  { numero: 32, titolo: "Sottrazioni con il cambio", slug: "bus3_mat_p032", view_template: "bus3_mat_p032" },
  { numero: 34, titolo: "Calcoli veloci - Esercizi", slug: "bus3_mat_p034", view_template: "bus3_mat_p034" },
  { numero: 35, titolo: "Calcoli veloci - Scomposizione", slug: "bus3_mat_p035", view_template: "bus3_mat_p035" },
  { numero: 74, titolo: "Le Frazioni", slug: "bus3_mat_p074", view_template: "bus3_mat_p074" },
  { numero: 75, titolo: "Leggere e scrivere le frazioni", slug: "bus3_mat_p075", view_template: "bus3_mat_p075" },
  { numero: 76, titolo: "Frazioni - L'unità frazionaria", slug: "bus3_mat_p076", view_template: "bus3_mat_p076" },
  { numero: 77, titolo: "Le Frazioni Equiestese", slug: "bus3_mat_p077", view_template: "bus3_mat_p077" },
  { numero: 78, titolo: "Dall'Unità Frazionaria all'Intero", slug: "bus3_mat_p078", view_template: "bus3_mat_p078" },
  { numero: 144, titolo: "Proprietà dell'Addizione", slug: "bus3_mat_p144", view_template: "bus3_mat_p144" }
].each do |pagina_data|
  bus_matematica.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{bus_volume3.nome}' con #{bus_matematica.pagine.count} pagine"

# 3b. BANDA DEL BUS 2
bus_volume2 = bus.volumi.create!(
  nome: "BUS 2",
  classe: 2,
  posizione: 2
)

bus2_lettura_grammatica = bus_volume2.discipline.create!(
  nome: "Lettura e Grammatica",
  codice: "lettgr",
  colore: "#F59E0B"
)

[
  { numero: 96, titolo: "Il Rimedio Più Bello (pag. 96-97)", slug: "bus2_lettgr_p096", view_template: "bus2_lettgr_p096" }
].each do |pagina_data|
  bus2_lettura_grammatica.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{bus_volume2.nome}' con #{bus2_lettura_grammatica.pagine.count} pagine"

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

# 5. NUOVO VIVA IMPARARE 5
nvi_volume5 = nvi.volumi.create!(
  nome: "Nuovo Viva Imparare 5",
  classe: 5,
  posizione: 5
)

nvi5_matematica = nvi_volume5.discipline.create!(
  nome: "Matematica",
  codice: "mat",
  colore: "#A855F7"
)

[
  { numero: 12, titolo: "I Numeri Romani", slug: "nvi5_mat_p012", view_template: "nvi5_mat_p012" },
  { numero: 13, titolo: "I Numeri Grandi", slug: "nvi5_mat_p013", view_template: "nvi5_mat_p013" },
  { numero: 14, titolo: "I Numeri Decimali", slug: "nvi5_mat_p014", view_template: "nvi5_mat_p014" },
  { numero: 15, titolo: "Arrotondamento o Approssimazione", slug: "nvi5_mat_p015", view_template: "nvi5_mat_p015" },
  { numero: 16, titolo: "Le Potenze", slug: "nvi5_mat_p016", view_template: "nvi5_mat_p016" },
  { numero: 17, titolo: "La Scrittura Polinomiale", slug: "nvi5_mat_p017", view_template: "nvi5_mat_p017" },
  { numero: 18, titolo: "I Numeri - Esercizi", slug: "nvi5_mat_p018", view_template: "nvi5_mat_p018" },
  { numero: 19, titolo: "Esercizi", slug: "nvi5_mat_p019", view_template: "nvi5_mat_p019" },
  { numero: 20, titolo: "I Numeri Interi Relativi", slug: "nvi5_mat_p020", view_template: "nvi5_mat_p020" },
  { numero: 21, titolo: "Confrontare e Ordinare i Numeri Interi Relativi", slug: "nvi5_mat_p021", view_template: "nvi5_mat_p021" },
  { numero: 22, titolo: "Operare con i Numeri Interi Relativi", slug: "nvi5_mat_p022", view_template: "nvi5_mat_p022" },
  { numero: 23, titolo: "La Calcolatrice", slug: "nvi5_mat_p023", view_template: "nvi5_mat_p023" },
  { numero: 24, titolo: "I Numeri Decimali e I Numeri Relativi", slug: "nvi5_mat_p024", view_template: "nvi5_mat_p024" },
  { numero: 25, titolo: "Mappa - Il Nostro Sistema di Numerazione", slug: "nvi5_mat_p025", view_template: "nvi5_mat_p025" },
  { numero: 26, titolo: "Verifica - I Numeri", slug: "nvi5_mat_p026", view_template: "nvi5_mat_p026" },
  { numero: 27, titolo: "Modello INVALSI - I Numeri", slug: "nvi5_mat_p027", view_template: "nvi5_mat_p027" },
  { numero: 28, titolo: "I Numeri - Verifica Avanzata", slug: "nvi5_mat_p028", view_template: "nvi5_mat_p028" },
  { numero: 29, titolo: "I Numeri - Esercizi Guidati", slug: "nvi5_mat_p029", view_template: "nvi5_mat_p029" }
].each do |pagina_data|
  nvi5_matematica.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{nvi_volume5.nome}' con #{nvi5_matematica.pagine.count} pagine"

# Riepilogo finale
puts "\n✅ Seed completato!"
puts "\n📊 Riepilogo:"
puts "   - #{Corso.count} corsi"
puts "   - #{Volume.count} volumi"
puts "   - #{Disciplina.count} discipline"
puts "   - #{Pagina.count} pagine"

puts "\n🚀 Puoi visitare http://localhost:3000 per vedere i corsi!"
