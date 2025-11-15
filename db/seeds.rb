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
  { numero: 1, titolo: "", slug: "nvl5_gram_p001", view_template: "nvl5_gram_p001", sottotitolo: "", base_color: "blue" },
  { numero: 2, titolo: "Indice", slug: "nvl5_gram_p002", view_template: "nvl5_gram_p002", sottotitolo: "Indice", base_color: "blue" },
  { numero: 4, titolo: "Ortografia", slug: "nvl5_gram_p004", view_template: "nvl5_gram_p004", sottotitolo: "PAROLE AL CENTRO", base_color: "pink" },
  { numero: 5, titolo: "Ortografia", slug: "nvl5_gram_p005", view_template: "nvl5_gram_p005", sottotitolo: "PAROLE AL CENTRO", base_color: "pink" },
  { numero: 6, titolo: "Riconoscere le difficoltà", slug: "nvl5_gram_p006", view_template: "nvl5_gram_p006", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 7, titolo: "Scrivere bene i testi", slug: "nvl5_gram_p007", view_template: "nvl5_gram_p007", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 8, titolo: "Viva il ripasso!", slug: "nvl5_gram_p008", view_template: "nvl5_gram_p008", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 9, titolo: "Ricordi il plurale di -CIA e -GIA?", slug: "nvl5_gram_p009", view_template: "nvl5_gram_p009", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 10, titolo: "La lettera H", slug: "nvl5_gram_p010", view_template: "nvl5_gram_p010", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 11, titolo: "LO/L'HO, LA/L'HA e altre forme", slug: "nvl5_gram_p011", view_template: "nvl5_gram_p011", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 12, titolo: "La divisione in sillabe", slug: "nvl5_gram_p012", view_template: "nvl5_gram_p012", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 13, titolo: "La lettera maiuscola", slug: "nvl5_gram_p013", view_template: "nvl5_gram_p013", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 14, titolo: "Monosillabi e accento", slug: "nvl5_gram_p014", view_template: "nvl5_gram_p014", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 15, titolo: "Monosillabi con e senza accento", slug: "nvl5_gram_p015", view_template: "nvl5_gram_p015", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 16, titolo: "L'elisione", slug: "nvl5_gram_p016", view_template: "nvl5_gram_p016", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 17, titolo: "Il troncamento", slug: "nvl5_gram_p017", view_template: "nvl5_gram_p017", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 18, titolo: "La punteggiatura", slug: "nvl5_gram_p018", view_template: "nvl5_gram_p018", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 19, titolo: "Discorso diretto e indiretto", slug: "nvl5_gram_p019", view_template: "nvl5_gram_p019", sottotitolo: "ORTOGRAFIA", base_color: "pink" },
  { numero: 20, titolo: "L'ortografia", slug: "nvl5_gram_p020", view_template: "nvl5_gram_p020", sottotitolo: "VERIFICA", base_color: "cyan" },
  { numero: 21, titolo: "Ortografia e accenti", slug: "nvl5_gram_p021", view_template: "nvl5_gram_p021", sottotitolo: "VERIFICA", base_color: "cyan" },
  { numero: 22, titolo: "Lessico", slug: "nvl5_gram_p022", view_template: "nvl5_gram_p022", sottotitolo: "PAROLE AL CENTRO", base_color: "blue" },
  { numero: 23, titolo: "Lessico e parole composte", slug: "nvl5_gram_p023", view_template: "nvl5_gram_p023", sottotitolo: "PAROLE AL CENTRO", base_color: "blue" },
  { numero: 24, titolo: "L'origine della lingua italiana", slug: "nvl5_gram_p024", view_template: "nvl5_gram_p024", sottotitolo: "LESSICO", base_color: "blue" },
  { numero: 25, titolo: "I dialetti", slug: "nvl5_gram_p025", view_template: "nvl5_gram_p025", sottotitolo: "LESSICO", base_color: "green" },
  { numero: 26, titolo: "La lingua nel tempo", slug: "nvl5_gram_p026", view_template: "nvl5_gram_p026", sottotitolo: "LESSICO", base_color: "purple" },
  { numero: 27, titolo: "Le parole in prestito", slug: "nvl5_gram_p027", view_template: "nvl5_gram_p027", sottotitolo: "LESSICO", base_color: "amber" },
  { numero: 28, titolo: "Sinonimi e contrari", slug: "nvl5_gram_p028", view_template: "nvl5_gram_p028", sottotitolo: "LESSICO", base_color: "pink" },
  { numero: 29, titolo: "Sinonimi e contrari - esercizi", slug: "nvl5_gram_p029", view_template: "nvl5_gram_p029", sottotitolo: "LESSICO", base_color: "amber" },
  { numero: 30, titolo: "Le sfumature dei sinonimi", slug: "nvl5_gram_p030", view_template: "nvl5_gram_p030", sottotitolo: "LESSICO", base_color: "amber" },
  { numero: 31, titolo: "Parole… in scala!", slug: "nvl5_gram_p031", view_template: "nvl5_gram_p031", sottotitolo: "LESSICO", base_color: "amber" },
  { numero: 32, titolo: "Le parole polisemiche", slug: "nvl5_gram_p032", view_template: "nvl5_gram_p032", sottotitolo: "LESSICO", base_color: "purple" },
  { numero: 33, titolo: "Gli omonimi", slug: "nvl5_gram_p033", view_template: "nvl5_gram_p033", sottotitolo: "LESSICO", base_color: "pink" },
  { numero: 34, titolo: "Il linguaggio settoriale", slug: "nvl5_gram_p034", view_template: "nvl5_gram_p034", sottotitolo: "LESSICO", base_color: "amber" },
  { numero: 35, titolo: "Linguaggio settoriale – esercizi", slug: "nvl5_gram_p035", view_template: "nvl5_gram_p035", sottotitolo: "LESSICO", base_color: "blue" },
  { numero: 36, titolo: "Il linguaggio figurato", slug: "nvl5_gram_p036", view_template: "nvl5_gram_p036", sottotitolo: "LESSICO", base_color: "amber" },
  { numero: 37, titolo: "Il linguaggio figurato – esercizi", slug: "nvl5_gram_p037", view_template: "nvl5_gram_p037", sottotitolo: "LESSICO", base_color: "cyan" },
  { numero: 38, titolo: "Il lessico (Parte 1)", slug: "nvl5_gram_p038", view_template: "nvl5_gram_p038", sottotitolo: "VERIFICA", base_color: "red" },
  { numero: 39, titolo: "Il lessico (Parte 2)", slug: "nvl5_gram_p039", view_template: "nvl5_gram_p039", sottotitolo: "VERIFICA", base_color: "orange" },
  { numero: 40, titolo: "Parole al centro – Morfologia", slug: "nvl5_gram_p040", view_template: "nvl5_gram_p040", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 41, titolo: "Parole al centro – Morfologia", slug: "nvl5_gram_p041", view_template: "nvl5_gram_p041", sottotitolo: "MORFOLOGIA", base_color: "purple" },
  { numero: 42, titolo: "Il genere dei nomi (Parte 1)", slug: "nvl5_gram_p042", view_template: "nvl5_gram_p042", sottotitolo: "MORFOLOGIA", base_color: "pink" },
  { numero: 43, titolo: "Il genere dei nomi (Parte 2)", slug: "nvl5_gram_p043", view_template: "nvl5_gram_p043", sottotitolo: "MORFOLOGIA", base_color: "pink" },
  { numero: 44, titolo: "Il numero dei nomi (Parte 1)", slug: "nvl5_gram_p044", view_template: "nvl5_gram_p044", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 45, titolo: "Il numero dei nomi (Parte 2)", slug: "nvl5_gram_p045", view_template: "nvl5_gram_p045", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 46, titolo: "Il significato dei nomi", slug: "nvl5_gram_p046", view_template: "nvl5_gram_p046", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 47, titolo: "La struttura dei nomi", slug: "nvl5_gram_p047", view_template: "nvl5_gram_p047", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 48, titolo: "Gli articoli", slug: "nvl5_gram_p048", view_template: "nvl5_gram_p048", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 49, titolo: "Gli articoli – esercizi", slug: "nvl5_gram_p049", view_template: "nvl5_gram_p049", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 50, titolo: "VERIFICA – Nomi e articoli", slug: "nvl5_gram_p050", view_template: "nvl5_gram_p050", sottotitolo: "VERIFICA", base_color: "red" },
  { numero: 51, titolo: "VERIFICA – Nomi e articoli (Tabella)", slug: "nvl5_gram_p051", view_template: "nvl5_gram_p051", sottotitolo: "VERIFICA", base_color: "red" },
  { numero: 52, titolo: "Gli aggettivi qualificativi", slug: "nvl5_gram_p052", view_template: "nvl5_gram_p052", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 53, titolo: "Gli aggettivi qualificativi – esercizi", slug: "nvl5_gram_p053", view_template: "nvl5_gram_p053", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 54, titolo: "I pronomi personali", slug: "nvl5_gram_p054", view_template: "nvl5_gram_p054", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 55, titolo: "I pronomi personali – particelle", slug: "nvl5_gram_p055", view_template: "nvl5_gram_p055", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 56, titolo: "Aggettivi e pronomi possessivi", slug: "nvl5_gram_p056", view_template: "nvl5_gram_p056", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 57, titolo: "Aggettivi e pronomi dimostrativi", slug: "nvl5_gram_p057", view_template: "nvl5_gram_p057", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 58, titolo: "Aggettivi e pronomi indefiniti", slug: "nvl5_gram_p058", view_template: "nvl5_gram_p058", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 59, titolo: "Aggettivi e pronomi indefiniti – esercizi", slug: "nvl5_gram_p059", view_template: "nvl5_gram_p059", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 60, titolo: "Aggettivi e pronomi interrogativi ed esclamativi", slug: "nvl5_gram_p060", view_template: "nvl5_gram_p060", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 61, titolo: "Aggettivi e pronomi interrogativi ed esclamativi – esercizi", slug: "nvl5_gram_p061", view_template: "nvl5_gram_p061", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 62, titolo: "I pronomi relativi", slug: "nvl5_gram_p062", view_template: "nvl5_gram_p062", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 63, titolo: "I pronomi relativi – esercizi", slug: "nvl5_gram_p063", view_template: "nvl5_gram_p063", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 64, titolo: "VERIFICA – Aggettivi e pronomi", slug: "nvl5_gram_p064", view_template: "nvl5_gram_p064", sottotitolo: "VERIFICA", base_color: "green" },
  { numero: 65, titolo: "VERIFICA – Aggettivi e pronomi", slug: "nvl5_gram_p065", view_template: "nvl5_gram_p065", sottotitolo: "VERIFICA", base_color: "green" },
  { numero: 66, titolo: "I verbi", slug: "nvl5_gram_p066", view_template: "nvl5_gram_p066", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 67, titolo: "Essere e avere", slug: "nvl5_gram_p067", view_template: "nvl5_gram_p067", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 68, titolo: "Il modo indicativo", slug: "nvl5_gram_p068", view_template: "nvl5_gram_p068", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 69, titolo: "Il modo indicativo – esercizi", slug: "nvl5_gram_p069", view_template: "nvl5_gram_p069", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 70, titolo: "Il modo congiuntivo", slug: "nvl5_gram_p070", view_template: "nvl5_gram_p070", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 71, titolo: "Il modo condizionale", slug: "nvl5_gram_p071", view_template: "nvl5_gram_p071", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 72, titolo: "Il condizionale e il congiuntivo", slug: "nvl5_gram_p072", view_template: "nvl5_gram_p072", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 73, titolo: "Il modo imperativo", slug: "nvl5_gram_p073", view_template: "nvl5_gram_p073", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 74, titolo: "I modi indefiniti", slug: "nvl5_gram_p074", view_template: "nvl5_gram_p074", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 75, titolo: "I modi indefiniti – esercizi", slug: "nvl5_gram_p075", view_template: "nvl5_gram_p075", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 76, titolo: "VERIFICA – I verbi • 1", slug: "nvl5_gram_p076", view_template: "nvl5_gram_p076", sottotitolo: "VERIFICA", base_color: "green" },
  { numero: 77, titolo: "VERIFICA – I verbi • 1", slug: "nvl5_gram_p077", view_template: "nvl5_gram_p077", sottotitolo: "VERIFICA", base_color: "green" },
  { numero: 78, titolo: "Verbi transitivi e verbi intransitivi", slug: "nvl5_gram_p078", view_template: "nvl5_gram_p078", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 79, titolo: "Verbi transitivi e intransitivi – esercizi", slug: "nvl5_gram_p079", view_template: "nvl5_gram_p079", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 80, titolo: "La forma attiva e la forma passiva", slug: "nvl5_gram_p080", view_template: "nvl5_gram_p080", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 81, titolo: "La forma attiva e passiva – esercizi", slug: "nvl5_gram_p081", view_template: "nvl5_gram_p081", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 82, titolo: "La forma riflessiva", slug: "nvl5_gram_p082", view_template: "nvl5_gram_p082", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 83, titolo: "Verbi impersonali", slug: "nvl5_gram_p083", view_template: "nvl5_gram_p083", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 84, titolo: "Verbi irregolari", slug: "nvl5_gram_p084", view_template: "nvl5_gram_p084", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 85, titolo: "Verbi servili", slug: "nvl5_gram_p085", view_template: "nvl5_gram_p085", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 86, titolo: "VERIFICA – I verbi • 2", slug: "nvl5_gram_p086", view_template: "nvl5_gram_p086", sottotitolo: "VERIFICA", base_color: "green" },
  { numero: 87, titolo: "VERIFICA – I verbi • 2", slug: "nvl5_gram_p087", view_template: "nvl5_gram_p087", sottotitolo: "VERIFICA", base_color: "green" },
  { numero: 88, titolo: "Gli avverbi", slug: "nvl5_gram_p088", view_template: "nvl5_gram_p088", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 89, titolo: "Gli avverbi – esercizi", slug: "nvl5_gram_p089", view_template: "nvl5_gram_p089", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 90, titolo: "Le locuzioni avverbiali", slug: "nvl5_gram_p090", view_template: "nvl5_gram_p090", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 91, titolo: "Le preposizioni", slug: "nvl5_gram_p091", view_template: "nvl5_gram_p091", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 92, titolo: "Le esclamazioni", slug: "nvl5_gram_p092", view_template: "nvl5_gram_p092", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 93, titolo: "Le congiunzioni", slug: "nvl5_gram_p093", view_template: "nvl5_gram_p093", sottotitolo: "MORFOLOGIA", base_color: "green" },
  { numero: 94, titolo: "VERIFICA – Le parti invariabili del discorso", slug: "nvl5_gram_p094", view_template: "nvl5_gram_p094", sottotitolo: "VERIFICA", base_color: "green" },
  { numero: 95, titolo: "VERIFICA – Le parti invariabili del discorso", slug: "nvl5_gram_p095", view_template: "nvl5_gram_p095", sottotitolo: "VERIFICA", base_color: "green" },
  { numero: 96, titolo: "Analizzare il nome e l'articolo", slug: "nvl5_gram_p096", view_template: "nvl5_gram_p096", sottotitolo: "ANALISI GRAMMATICALE", base_color: "blue" },
  { numero: 97, titolo: "Analizzare l'aggettivo e il pronome", slug: "nvl5_gram_p097", view_template: "nvl5_gram_p097", sottotitolo: "ANALISI GRAMMATICALE", base_color: "blue" },
  { numero: 98, titolo: "Analizzare il verbo", slug: "nvl5_gram_p098", view_template: "nvl5_gram_p098", sottotitolo: "ANALISI GRAMMATICALE", base_color: "blue" },
  { numero: 99, titolo: "Analisi grammaticale completa", slug: "nvl5_gram_p099", view_template: "nvl5_gram_p099", sottotitolo: "ANALISI GRAMMATICALE", base_color: "blue" },
  { numero: 100, titolo: "Parole al centro – Sintassi", slug: "nvl5_gram_p100", view_template: "nvl5_gram_p100", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 101, titolo: "Parole al centro – Sintassi", slug: "nvl5_gram_p101", view_template: "nvl5_gram_p101", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 102, titolo: "La frase", slug: "nvl5_gram_p102", view_template: "nvl5_gram_p102", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 103, titolo: "La frase minima", slug: "nvl5_gram_p103", view_template: "nvl5_gram_p103", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 104, titolo: "Il soggetto", slug: "nvl5_gram_p104", view_template: "nvl5_gram_p104", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 105, titolo: "Il predicato", slug: "nvl5_gram_p105", view_template: "nvl5_gram_p105", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 106, titolo: "Il complemento oggetto", slug: "nvl5_gram_p106", view_template: "nvl5_gram_p106", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 107, titolo: "Il complemento di termine", slug: "nvl5_gram_p107", view_template: "nvl5_gram_p107", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 108, titolo: "Il complemento di specificazione", slug: "nvl5_gram_p108", view_template: "nvl5_gram_p108", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 109, titolo: "Il complemento di specificazione", slug: "nvl5_gram_p109", view_template: "nvl5_gram_p109", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 110, titolo: "I complementi di luogo", slug: "nvl5_gram_p110", view_template: "nvl5_gram_p110", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 111, titolo: "I complementi di tempo", slug: "nvl5_gram_p111", view_template: "nvl5_gram_p111", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 112, titolo: "Il complemento di mezzo", slug: "nvl5_gram_p112", view_template: "nvl5_gram_p112", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 113, titolo: "Altri complementi indiretti", slug: "nvl5_gram_p113", view_template: "nvl5_gram_p113", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 114, titolo: "L'attributo", slug: "nvl5_gram_p114", view_template: "nvl5_gram_p114", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 115, titolo: "L'apposizione", slug: "nvl5_gram_p115", view_template: "nvl5_gram_p115", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 116, titolo: "VERIFICA - La sintassi", slug: "nvl5_gram_p116", view_template: "nvl5_gram_p116", sottotitolo: "VERIFICA", base_color: "orange" },
  { numero: 117, titolo: "Complementi e analisi", slug: "nvl5_gram_p117", view_template: "nvl5_gram_p117", sottotitolo: "VERIFICA", base_color: "orange" },
  { numero: 118, titolo: "L'analisi logica della frase", slug: "nvl5_gram_p118", view_template: "nvl5_gram_p118", sottotitolo: "ANALISI LOGICA", base_color: "blue" },
  { numero: 119, titolo: "Esercizi", slug: "nvl5_gram_p119", view_template: "nvl5_gram_p119", sottotitolo: "ANALISI LOGICA", base_color: "blue" },
  { numero: 120, titolo: "La grammatica valenziale", slug: "nvl5_gram_p120", view_template: "nvl5_gram_p120", sottotitolo: "GRAMMATICA VALENZIALE", base_color: "blue" },
  { numero: 121, titolo: "La grammatica valenziale - Esercizi", slug: "nvl5_gram_p121", view_template: "nvl5_gram_p121", sottotitolo: "GRAMMATICA VALENZIALE", base_color: "blue" },
  { numero: 122, titolo: "Frase semplice e frase complessa", slug: "nvl5_gram_p122", view_template: "nvl5_gram_p122", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 123, titolo: "Frasi principali e secondarie - 1", slug: "nvl5_gram_p123", view_template: "nvl5_gram_p123", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 124, titolo: "Frasi principali e secondarie - 2", slug: "nvl5_gram_p124", view_template: "nvl5_gram_p124", sottotitolo: "SINTASSI", base_color: "orange" },
  { numero: 125, titolo: "Quaderno degli esercizi", slug: "nvl5_gram_p125", view_template: "nvl5_gram_p125", sottotitolo: "QUADERNO DEGLI ESERCIZI", base_color: "cyan" },
  { numero: 126, titolo: "ESSERE - Tavola dei verbi", slug: "nvl5_gram_p126", view_template: "nvl5_gram_p126", sottotitolo: "TAVOLE DEI VERBI", base_color: "cyan" },
  { numero: 127, titolo: "AVERE - Tavola dei verbi", slug: "nvl5_gram_p127", view_template: "nvl5_gram_p127", sottotitolo: "TAVOLE DEI VERBI", base_color: "cyan" },
  { numero: 128, titolo: "Coniugazione dei verbi regolari", slug: "nvl5_gram_p128", view_template: "nvl5_gram_p128", sottotitolo: "TAVOLE DEI VERBI", base_color: "cyan" },
  { numero: 129, titolo: "Coniugazione dei verbi regolari (continua)", slug: "nvl5_gram_p129", view_template: "nvl5_gram_p129", sottotitolo: "TAVOLE DEI VERBI", base_color: "cyan" },
  { numero: 130, titolo: "Verbi irregolari - 1ª coniugazione", slug: "nvl5_gram_p130", view_template: "nvl5_gram_p130", sottotitolo: "TAVOLE DEI VERBI", base_color: "cyan" },
  { numero: 131, titolo: "Verbi irregolari - 2ª coniugazione (BERE, CADERE, DOVERE)", slug: "nvl5_gram_p131", view_template: "nvl5_gram_p131", sottotitolo: "TAVOLE DEI VERBI", base_color: "cyan" },
  { numero: 132, titolo: "Verbi irregolari - 2ª coniugazione (POTERE, SAPERE, VOLERE)", slug: "nvl5_gram_p132", view_template: "nvl5_gram_p132", sottotitolo: "TAVOLE DEI VERBI", base_color: "cyan" },
  { numero: 133, titolo: "Verbi irregolari - 3ª coniugazione (DIRE, SALIRE, VENIRE)", slug: "nvl5_gram_p133", view_template: "nvl5_gram_p133", sottotitolo: "TAVOLE DEI VERBI", base_color: "cyan" },
  { numero: 134, titolo: "Coniugazione riflessiva: LAVARSI", slug: "nvl5_gram_p134", view_template: "nvl5_gram_p134", sottotitolo: "TAVOLE DEI VERBI", base_color: "cyan" },
  { numero: 135, titolo: "Coniugazione passiva: ESSERE AMATO", slug: "nvl5_gram_p135", view_template: "nvl5_gram_p135", sottotitolo: "TAVOLE DEI VERBI", base_color: "cyan" },
  { numero: 136, titolo: "Pronomi accoppiati, apostrofo e H", slug: "nvl5_gram_p136", view_template: "nvl5_gram_p136", sottotitolo: "ORTOGRAFIA", base_color: "cyan" },
  { numero: 137, titolo: "Pronomi accoppiati (continua)", slug: "nvl5_gram_p137", view_template: "nvl5_gram_p137", sottotitolo: "ORTOGRAFIA", base_color: "cyan" },
  { numero: 138, titolo: "Monosillabi e accento", slug: "nvl5_gram_p138", view_template: "nvl5_gram_p138", sottotitolo: "ORTOGRAFIA", base_color: "cyan" },
  { numero: 139, titolo: "L'elisione e il troncamento", slug: "nvl5_gram_p139", view_template: "nvl5_gram_p139", sottotitolo: "ORTOGRAFIA", base_color: "cyan" },
  { numero: 140, titolo: "Neologismi e arcaismi", slug: "nvl5_gram_p140", view_template: "nvl5_gram_p140", sottotitolo: "LESSICO", base_color: "cyan" },
  { numero: 141, titolo: "Esprimersi bene", slug: "nvl5_gram_p141", view_template: "nvl5_gram_p141", sottotitolo: "LESSICO", base_color: "cyan" },
  { numero: 142, titolo: "Il linguaggio settoriale", slug: "nvl5_gram_p142", view_template: "nvl5_gram_p142", sottotitolo: "LESSICO", base_color: "cyan" },
  { numero: 143, titolo: "Il linguaggio figurato", slug: "nvl5_gram_p143", view_template: "nvl5_gram_p143", sottotitolo: "LESSICO", base_color: "cyan" },
  { numero: 144, titolo: "Verso la prova INVALSI - Lessico", slug: "nvl5_gram_p144", view_template: "nvl5_gram_p144", sottotitolo: "VERSO LA PROVA INVALSI", base_color: "red" },
  { numero: 145, titolo: "Verso la prova INVALSI - Lessico (continua)", slug: "nvl5_gram_p145", view_template: "nvl5_gram_p145", sottotitolo: "VERSO LA PROVA INVALSI", base_color: "red" },
  { numero: 146, titolo: "I nomi", slug: "nvl5_gram_p146", view_template: "nvl5_gram_p146", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 147, titolo: "Genere e numero", slug: "nvl5_gram_p147", view_template: "nvl5_gram_p147", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 148, titolo: "Difettivi, sovrabbondanti, invariabili", slug: "nvl5_gram_p148", view_template: "nvl5_gram_p148", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 149, titolo: "Nomi collettivi e nomi composti", slug: "nvl5_gram_p149", view_template: "nvl5_gram_p149", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 150, titolo: "Nomi primitivi, derivati e alterati", slug: "nvl5_gram_p150", view_template: "nvl5_gram_p150", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 151, titolo: "Nomi primitivi, derivati e alterati (continua)", slug: "nvl5_gram_p151", view_template: "nvl5_gram_p151", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 152, titolo: "Gli articoli", slug: "nvl5_gram_p152", view_template: "nvl5_gram_p152", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 153, titolo: "Ancora articoli e nomi", slug: "nvl5_gram_p153", view_template: "nvl5_gram_p153", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 154, titolo: "Gli aggettivi qualificativi", slug: "nvl5_gram_p154", view_template: "nvl5_gram_p154", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 155, titolo: "Gli aggettivi qualificativi (continua)", slug: "nvl5_gram_p155", view_template: "nvl5_gram_p155", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 156, titolo: "I gradi dell'aggettivo", slug: "nvl5_gram_p156", view_template: "nvl5_gram_p156", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 157, titolo: "I gradi dell'aggettivo (continua)", slug: "nvl5_gram_p157", view_template: "nvl5_gram_p157", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 158, titolo: "Gli aggettivi e i pronomi dimostrativi", slug: "nvl5_gram_p158", view_template: "nvl5_gram_p158", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 159, titolo: "Gli aggettivi e i pronomi possessivi", slug: "nvl5_gram_p159", view_template: "nvl5_gram_p159", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 160, titolo: "Gli aggettivi e i pronomi indefiniti", slug: "nvl5_gram_p160", view_template: "nvl5_gram_p160", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 161, titolo: "Gli aggettivi e i pronomi indefiniti (continua)", slug: "nvl5_gram_p161", view_template: "nvl5_gram_p161", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 162, titolo: "Gli aggettivi numerali e interrogativi", slug: "nvl5_gram_p162", view_template: "nvl5_gram_p162", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 163, titolo: "I pronomi personali", slug: "nvl5_gram_p163", view_template: "nvl5_gram_p163", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 164, titolo: "I pronomi personali (continua)", slug: "nvl5_gram_p164", view_template: "nvl5_gram_p164", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 165, titolo: "I pronomi relativi", slug: "nvl5_gram_p165", view_template: "nvl5_gram_p165", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 166, titolo: "I verbi: modo e tempo", slug: "nvl5_gram_p166", view_template: "nvl5_gram_p166", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 167, titolo: "I verbi: persona e numero", slug: "nvl5_gram_p167", view_template: "nvl5_gram_p167", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 168, titolo: "I verbi: transitivi e intransitivi", slug: "nvl5_gram_p168", view_template: "nvl5_gram_p168", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 169, titolo: "I verbi: forma attiva e passiva", slug: "nvl5_gram_p169", view_template: "nvl5_gram_p169", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 170, titolo: "I verbi: forma riflessiva", slug: "nvl5_gram_p170", view_template: "nvl5_gram_p170", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 171, titolo: "I verbi: ausiliari e servili", slug: "nvl5_gram_p171", view_template: "nvl5_gram_p171", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 172, titolo: "I verbi: impersonali e difettivi", slug: "nvl5_gram_p172", view_template: "nvl5_gram_p172", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 173, titolo: "Le coniugazioni", slug: "nvl5_gram_p173", view_template: "nvl5_gram_p173", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 174, titolo: "Le coniugazioni (continua)", slug: "nvl5_gram_p174", view_template: "nvl5_gram_p174", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 175, titolo: "Gli avverbi", slug: "nvl5_gram_p175", view_template: "nvl5_gram_p175", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 176, titolo: "Le preposizioni", slug: "nvl5_gram_p176", view_template: "nvl5_gram_p176", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 177, titolo: "Le congiunzioni", slug: "nvl5_gram_p177", view_template: "nvl5_gram_p177", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 178, titolo: "Le esclamazioni", slug: "nvl5_gram_p178", view_template: "nvl5_gram_p178", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 179, titolo: "Analisi grammaticale", slug: "nvl5_gram_p179", view_template: "nvl5_gram_p179", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 180, titolo: "Analisi grammaticale (continua)", slug: "nvl5_gram_p180", view_template: "nvl5_gram_p180", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 181, titolo: "Verso la prova INVALSI - Morfologia", slug: "nvl5_gram_p181", view_template: "nvl5_gram_p181", sottotitolo: "MORFOLOGIA", base_color: "cyan" },
  { numero: 182, titolo: "Il soggetto e il predicato", slug: "nvl5_gram_p182", view_template: "nvl5_gram_p182", sottotitolo: "SINTASSI", base_color: "cyan" },
  { numero: 183, titolo: "Il complemento oggetto", slug: "nvl5_gram_p183", view_template: "nvl5_gram_p183", sottotitolo: "SINTASSI", base_color: "cyan" },
  { numero: 184, titolo: "I complementi di termine e di specificazione", slug: "nvl5_gram_p184", view_template: "nvl5_gram_p184", sottotitolo: "SINTASSI", base_color: "cyan" },
  { numero: 185, titolo: "I complementi di luogo e di tempo", slug: "nvl5_gram_p185", view_template: "nvl5_gram_p185", sottotitolo: "SINTASSI", base_color: "cyan" },
  { numero: 186, titolo: "I complementi di mezzo e di causa", slug: "nvl5_gram_p186", view_template: "nvl5_gram_p186", sottotitolo: "SINTASSI", base_color: "cyan" },
  { numero: 187, titolo: "Quanti complementi!", slug: "nvl5_gram_p187", view_template: "nvl5_gram_p187", sottotitolo: "SINTASSI", base_color: "cyan" },
  { numero: 188, titolo: "Attributo e apposizione", slug: "nvl5_gram_p188", view_template: "nvl5_gram_p188", sottotitolo: "SINTASSI", base_color: "cyan" },
  { numero: 189, titolo: "Frase semplice e frase complessa", slug: "nvl5_gram_p189", view_template: "nvl5_gram_p189", sottotitolo: "SINTASSI", base_color: "cyan" },
  { numero: 190, titolo: "Sintassi (Parte 1)", slug: "nvl5_gram_p190", view_template: "nvl5_gram_p190", sottotitolo: "VERSO LA PROVA INVALSI", base_color: "red" },
  { numero: 191, titolo: "Sintassi (Parte 2)", slug: "nvl5_gram_p191", view_template: "nvl5_gram_p191", sottotitolo: "VERSO LA PROVA INVALSI", base_color: "red" }
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
  { numero: 1, titolo: "Copertina", slug: "nvi5_mat_p001", view_template: "nvi5_mat_p001", sottotitolo: "", base_color: "pink" },
  { numero: 2, titolo: "Indice", slug: "nvi5_mat_p002", view_template: "nvi5_mat_p002", sottotitolo: "", base_color: "pink" },
  { numero: 4, titolo: "Numeri - Misura - Geometria", slug: "nvi5_mat_p004", view_template: "nvi5_mat_p004", sottotitolo: "PER RICOMINCIARE", base_color: "pink" },
  { numero: 5, titolo: "Numeri - Misura - Geometria", slug: "nvi5_mat_p005", view_template: "nvi5_mat_p005", sottotitolo: "PER RICOMINCIARE", base_color: "pink" },
  { numero: 12, titolo: "I Numeri Romani", slug: "nvi5_mat_p012", view_template: "nvi5_mat_p012", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 13, titolo: "I Numeri Grandi", slug: "nvi5_mat_p013", view_template: "nvi5_mat_p013", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 14, titolo: "I Numeri Decimali", slug: "nvi5_mat_p014", view_template: "nvi5_mat_p014", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 15, titolo: "Arrotondamento o Approssimazione", slug: "nvi5_mat_p015", view_template: "nvi5_mat_p015", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 16, titolo: "Le Potenze", slug: "nvi5_mat_p016", view_template: "nvi5_mat_p016", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 17, titolo: "La Scrittura Polinomiale", slug: "nvi5_mat_p017", view_template: "nvi5_mat_p017", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 18, titolo: "I Numeri - Esercizi", slug: "nvi5_mat_p018", view_template: "nvi5_mat_p018", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 19, titolo: "Esercizi", slug: "nvi5_mat_p019", view_template: "nvi5_mat_p019" },
  { numero: 20, titolo: "I Numeri Interi Relativi", slug: "nvi5_mat_p020", view_template: "nvi5_mat_p020" },
  { numero: 21, titolo: "Confrontare e Ordinare i Numeri Interi Relativi", slug: "nvi5_mat_p021", view_template: "nvi5_mat_p021" },
  { numero: 22, titolo: "Operare con i Numeri Interi Relativi", slug: "nvi5_mat_p022", view_template: "nvi5_mat_p022" },
  { numero: 23, titolo: "La Calcolatrice", slug: "nvi5_mat_p023", view_template: "nvi5_mat_p023" },
  { numero: 24, titolo: "I Numeri Decimali e I Numeri Relativi", slug: "nvi5_mat_p024", view_template: "nvi5_mat_p024" },
  { numero: 25, titolo: "Mappa - Il Nostro Sistema di Numerazione", slug: "nvi5_mat_p025", view_template: "nvi5_mat_p025" },
  { numero: 26, titolo: "I Numeri", slug: "nvi5_mat_p026", view_template: "nvi5_mat_p026", sottotitolo: "VERIFICA", base_color: "cyan" },
  { numero: 27, titolo: "I Numeri", slug: "nvi5_mat_p027", view_template: "nvi5_mat_p027", sottotitolo: "MODELLO INVALSI", base_color: "red" },
  { numero: 28, titolo: "I Numeri - Verifica Avanzata", slug: "nvi5_mat_p028", view_template: "nvi5_mat_p028", sottotitolo: "MODELLO INVALSI", base_color: "red" },
  { numero: 29, titolo: "I Numeri - Esercizi Guidati", slug: "nvi5_mat_p029", view_template: "nvi5_mat_p029", sottotitolo: "MODELLO INVALSI", base_color: "red" },
  { numero: 56, titolo: "???", slug: "nvi5_mat_p056", view_template: "nvi5_mat_p056", sottotitolo: "???", base_color: "blue" },
  { numero: 57, titolo: "Frazioni Proprie, Improprie e Apparenti", slug: "nvi5_mat_p057", view_template: "nvi5_mat_p057" },
  { numero: 58, titolo: "Laboratorio - Ricostruiamo l'Intero", slug: "nvi5_mat_p058", view_template: "nvi5_mat_p058" },
  { numero: 59, titolo: "Laboratorio - Ricostruiamo l'Intero (Frazioni Qualsiasi)", slug: "nvi5_mat_p059", view_template: "nvi5_mat_p059" },
  { numero: 60, titolo: "Confrontiamo le Frazioni", slug: "nvi5_mat_p060", view_template: "nvi5_mat_p060" },
  { numero: 61, titolo: "Confrontare le Frazioni - Il Prodotto in Croce", slug: "nvi5_mat_p061", view_template: "nvi5_mat_p061" },
  { numero: 62, titolo: "Addizioni e Sottrazioni con le Frazioni", slug: "nvi5_mat_p062", view_template: "nvi5_mat_p062" },
  { numero: 63, titolo: "La Frazione come Operatore", slug: "nvi5_mat_p063", view_template: "nvi5_mat_p063" },
  { numero: 64, titolo: "Dalla Frazione all'Intero", slug: "nvi5_mat_p064", view_template: "nvi5_mat_p064" },
  { numero: 65, titolo: "Frazioni Decimali e Numeri Decimali", slug: "nvi5_mat_p065", view_template: "nvi5_mat_p065" },
  { numero: 66, titolo: "Confronti e Operazioni con le Frazioni", slug: "nvi5_mat_p066", view_template: "nvi5_mat_p066" },
  { numero: 67, titolo: "La Percentuale", slug: "nvi5_mat_p067", view_template: "nvi5_mat_p067" },
  { numero: 68, titolo: "Lo Sconto e l'Interesse", slug: "nvi5_mat_p068", view_template: "nvi5_mat_p068" },
  { numero: 69, titolo: "Esercizi sulla Percentuale", slug: "nvi5_mat_p069", view_template: "nvi5_mat_p069" },
  { numero: 70, titolo: "Verifica - Frazioni e Percentuale", slug: "nvi5_mat_p070", view_template: "nvi5_mat_p070" },
  { numero: 71, titolo: "Modello INVALSI - Frazioni e Percentuale", slug: "nvi5_mat_p071", view_template: "nvi5_mat_p071" },
  { numero: 72, titolo: "Risolvere Problemi - Usare le Immagini", slug: "nvi5_mat_p072", view_template: "nvi5_mat_p072" },
  { numero: 73, titolo: "Esercizi - Risolvere Problemi", slug: "nvi5_mat_p073", view_template: "nvi5_mat_p073" },
  { numero: 74, titolo: "Riflettere sui Dati e sul Risultato", slug: "nvi5_mat_p074", view_template: "nvi5_mat_p074" }
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
