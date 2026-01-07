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
  { numero: 8, titolo: "Uguali o Diversi?", slug: "ci1_sta_p008", view_template: "ci1_sta_p008" },
  { numero: 10, titolo: "Come Inizia?", slug: "ci1_sta_p010", view_template: "ci1_sta_p010" },
  { numero: 10, titolo: "Come Inizia? (bis)", slug: "ci1_sta_p010gen", view_template: "ci1_sta_p010gen" },
  { numero: 22, titolo: "Lettera A - Scrivo", slug: "ci1_sta_p022", view_template: "ci1_sta_p022" },
  { numero: 23, titolo: "Lettera A - Leggo", slug: "ci1_sta_p023", view_template: "ci1_sta_p023" },
  { numero: 41, titolo: "Lettera O - Leggo", slug: "ci1_sta_p041", view_template: "ci1_sta_p041" },
  { numero: 43, titolo: "Lettera U - Scopro il suono", slug: "ci1_sta_p043", view_template: "ci1_sta_p043" },
  { numero: 50, titolo: "Esercizio pagina 50", slug: "ci1_sta_p050", view_template: "ci1_sta_p050" },
  { numero: 51, titolo: "Esercizio pagina 51", slug: "ci1_sta_p051", view_template: "ci1_sta_p051" },
  { numero: 167, titolo: "Esercizio pagina 167", slug: "ci1_sta_p167", view_template: "ci1_sta_p167" }
].each do |pagina_data|
  cai_metodo.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{cai_volume1.nome}' con #{cai_metodo.pagine.count} pagine"
