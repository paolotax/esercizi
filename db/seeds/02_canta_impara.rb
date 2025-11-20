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
